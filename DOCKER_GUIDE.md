# Docker Compose Setup & Architecture Guide

This containerized environment runs a multi-container stack for local Laravel development with **zero host-level dependencies** (meaning no PHP, Composer, Node/NPM, MySQL, or Redis are installed on your computer). 

All configurations are kept in a dedicated sibling directory `C:\Users\MSI\Documents\CODE\side-project\docker` to keep your `my-app` codebase clean of environment configuration files.

---

## 1. Directory Structure

```
C:\Users\MSI\Documents\CODE\side-project\
├── docker/
│   ├── docker-compose.yml     # Multi-container service definitions
│   ├── Dockerfile             # PHP FPM & development extensions recipe
│   ├── docker-entrypoint.sh   # Automation script executed on container boot
│   └── nginx.conf             # Nginx server virtual host definition
└── my-app/                    # Laravel Application Directory (Bind-Mounted)
    ├── package.json           # Frontend packages
    ├── vite.config.js         # Modified for Hot Module Replacement (HMR) inside Docker
    └── ...
```

---

## 2. Container Services Breakdown

Docker Compose sets up **6 services** communicating through a private virtual network bridge:

1. **`php` (PHP 8.3 FPM)**
   - **Base**: `php:8.3-fpm` (Debian slim).
   - **Role**: Runs the Laravel backend application core, executing FPM requests, background processes, database seeds, and migrations.
   - **Dependencies**: Waits for `db` and `redis` containers to report healthy before starting.
2. **`nginx` (Web Server)**
   - **Base**: `nginx:alpine` (Lightweight web server).
   - **Role**: Serves public assets (images, CSS, JS) directly and forwards `.php` requests to the `php` container's port `9000`. It is exposed to your host machine at **[http://localhost:8000](http://localhost:8000)**.
3. **`db` (MySQL 8.0)**
   - **Role**: Relational database storage. Data persists via a named Docker volume (`db_data`) so databases are not deleted when containers stop. Exposed to the host at port **`3306`** (username: `sail`, password: `password`, database: `laravel`).
4. **`redis` (Caching/Queues)**
   - **Role**: Stores cache, session states, and handles high-performance queue jobs. Data is persisted to `redis_data`. Exposed on port **`6379`**.
5. **`node` (Vite / Frontend Assets)**
   - **Base**: `node:20-alpine`.
   - **Role**: Automatically installs node dependencies (`npm install`) on boot, watches code files, compiles assets (Vue/JS/Tailwind CSS), and runs the Vite Dev Server with HMR at **[http://localhost:5173](http://localhost:5173)**.
6. **`mailpit` (SMTP Mail Catcher)**
   - **Role**: Automatically intercepts any emails sent by the Laravel system (configured to listen to SMTP port `1025`). Provides a gorgeous webmail inbox viewer UI at **[http://localhost:8025](http://localhost:8025)**.

---

## 3. Ports Mapping Reference

| Service | Host Port | Container Port | Protocol | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Nginx** | 8000 | 80 | HTTP | Web Access to Laravel App |
| **Node/Vite** | 5173 | 5173 | TCP | Vite Asset HMR / CSS & JS reload |
| **MySQL** | 3306 | 3306 | TCP | DB Connection (e.g. TablePlus, DBeaver) |
| **Redis** | 6379 | 6379 | TCP | Redis CLI access / Cache monitoring |
| **Mailpit Web** | 8025 | 8025 | HTTP | Web interface to view sent emails |

---

## 4. How the Configuration Files Interlock

### A. Dockerfile (PHP-FPM Customization)
Installs necessary packages for Laravel development:
- **Extensions**: `pdo_mysql` (database driver), `zip`, `gd` (image processing), `bcmath` (high-precision math), `pcntl` (multi-process control), and `redis`.
- **Debugging**: `xdebug` is compiled and pre-configured to communicate back to the host IDE (port `9003`).
- **Composer**: Copies the official binary directly from `composer:latest`.

### B. docker-entrypoint.sh (Automation Lifecycle)
When the PHP container starts:
1. Copies `.env.example` to `.env` if missing.
2. Automates changing the database/redis/mail hostnames inside `.env` from local `127.0.0.1` to the container names (`db`, `redis`, `mailpit`).
3. Executes `composer install` if the `vendor/` folder is empty.
4. Generates the `APP_KEY` if not set.
5. Fixes folder permissions for `storage/` and `bootstrap/cache/` to ensure the webserver can write files.
6. Boots `php-fpm` to handle Nginx requests.

### C. vite.config.js (Vite HMR Resolution)
In Docker, Vite binds to `0.0.0.0` to receive client HMR connections. By default, Chromium inside Alpine outputs `http://[::]:5173` to `public/hot`. Since your Windows host browser cannot resolve `[::]`, we configured Vite to output `localhost` explicitly:
```javascript
server: {
    host: '0.0.0.0',
    hmr: {
        host: 'localhost',
    },
}
```
This forces Laravel to fetch Vite compilation files from `http://localhost:5173`, resolving the broken UI issue.

---

## 5. Development Operations Cheatsheet

Since all command-line executables reside inside containers, run them via `docker compose` from the `docker` folder (`C:\Users\MSI\Documents\CODE\side-project\docker`):

### Stack Management
- **Start all services**: `docker compose up -d`
- **Rebuild and start**: `docker compose up -d --build`
- **Stop all services**: `docker compose down`
- **Stop and wipe volumes**: `docker compose down -v`

### Running Artisan Commands
Execute Laravel Artisan commands inside the running `php` container:
```powershell
docker compose exec php php artisan migrate
docker compose exec php php artisan db:seed
docker compose exec php php artisan make:controller PostController
docker compose exec php php artisan route:list
```

### Running Composer Commands
Pull down or update packages without host Composer:
```powershell
docker compose exec php composer require laravel/sanctum
docker compose exec php composer update
```

### Running Node/NPM Commands
Manage packages or build files inside the `node` container:
```powershell
docker compose exec node npm install axios
docker compose exec node npm run build
```

### Viewing Logs
Monitor output from specific containers:
```powershell
docker compose logs -f php
docker compose logs -f nginx
docker compose logs -f node
```
