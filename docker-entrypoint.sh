#!/bin/bash
set -e

# Function to set or update env variables
set_env() {
    local key=$1
    local value=$2
    # Check if key is commented out
    if grep -q "^#\s*${key}=" .env; then
        # Uncomment and set value
        sed -i "s|^#\s*${key}=.*|${key}=${value}|" .env
    # Check if key exists
    elif grep -q "^${key}=" .env; then
        # Update value
        sed -i "s|^${key}=.*|${key}=${value}|" .env
    else
        # Append value
        echo "${key}=${value}" >> .env
    fi
}

# Copy env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
fi

# Configure .env to connect to Docker services
echo "Updating .env configuration for Docker services..."
set_env "DB_CONNECTION" "mysql"
set_env "DB_HOST" "db"
set_env "DB_PORT" "3306"
set_env "DB_DATABASE" "laravel"
set_env "DB_USERNAME" "sail"
set_env "DB_PASSWORD" "password"

set_env "REDIS_HOST" "redis"
set_env "REDIS_PORT" "6379"

set_env "MAIL_MAILER" "smtp"
set_env "MAIL_HOST" "mailpit"
set_env "MAIL_PORT" "1025"

# Install Composer dependencies if vendor folder is missing
if [ ! -d vendor ]; then
    echo "Installing Composer dependencies..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Generate application key if not set
if [ -f .env ] && ! grep -q "APP_KEY=base64:" .env; then
    echo "Generating application key..."
    php artisan key:generate
fi

# Ensure storage and bootstrap/cache directories exist and are writable
echo "Setting storage and bootstrap/cache permissions..."
mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache
chmod -R 777 storage bootstrap/cache

# Execute the main container command
exec "$@"
