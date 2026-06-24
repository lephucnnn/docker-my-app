# Complete Xdebug Debugging Guide

## Quick Setup Checklist

### 1. Install Xdebug
- [ ] Download `php_xdebug-3.3.2-8.3-nts-x86_64.dll` from https://xdebug.org/download
- [ ] Copy to `C:\Program Files\php-8.3.6\ext\`
- [ ] Add configuration to `C:\Program Files\php-8.3.6\php.ini`
- [ ] Restart terminal/server

### 2. Verify Installation
```bash
php -r "echo extension_loaded('xdebug') ? 'SUCCESS' : 'FAILED';"
```

### 3. Test Debugging

#### Option A: Test with PHP Script
1. Open `test_xdebug.php` in VS Code
2. Set breakpoint on line 12
3. Press F5, select "Launch currently open script"
4. Should stop at breakpoint

#### Option B: Test with Laravel Route
1. Start Laravel server: `php artisan serve`
2. Open TodoController.php in VS Code
3. Set breakpoint in any method (e.g., line 15 in `getTodos()`)
4. Press F5, select "Listen for Xdebug (Laravel)"
5. Visit http://localhost:8000/debug-test in browser
6. Should stop at breakpoint

## Debug Configurations Explained

### "Listen for Xdebug (Laravel)" - RECOMMENDED
- Best for Laravel web debugging
- Ignores vendor files
- Optimized path mappings

### "Listen for Xdebug" 
- Generic Xdebug listener
- Good for general PHP projects

### "Launch currently open script"
- Debug single PHP files
- Perfect for testing Xdebug setup

### "Launch Built-in web server"
- Starts PHP built-in server with Xdebug
- Alternative to `php artisan serve`

## Debugging Workflow

### 1. Set Breakpoints
- Click left margin next to line numbers
- Red dots indicate breakpoints
- Right-click for conditional breakpoints

### 2. Start Debugging
- Press F5 or Run > Start Debugging
- Choose "Listen for Xdebug (Laravel)"
- Look for "Listening for Xdebug..." in Debug Console

### 3. Trigger Code
- Visit your Laravel app in browser
- Make API requests
- Run artisan commands

### 4. Debug Controls
- **Continue (F5)**: Resume execution
- **Step Over (F10)**: Execute next line
- **Step Into (F11)**: Enter function calls
- **Step Out (Shift+F11)**: Exit current function
- **Restart (Ctrl+Shift+F5)**: Restart debugging
- **Stop (Shift+F5)**: Stop debugging

## Common Issues & Solutions

### Issue: Breakpoints not hit
**Solutions:**
1. Check Xdebug is loaded: `php -r "var_dump(extension_loaded('xdebug'));"`
2. Verify port 9003 is not blocked by firewall
3. Ensure `xdebug.start_with_request=yes` in php.ini
4. Check Debug Console for connection messages

### Issue: "Cannot connect to runtime process"
**Solutions:**
1. Verify Laravel server is running: `php artisan serve`
2. Check if VS Code is listening: Look for debug console message
3. Try different debug configuration

### Issue: Variables not showing
**Solutions:**
1. Ensure you're stopped at a breakpoint
2. Check Variables panel in Debug sidebar
3. Use Debug Console to evaluate expressions

## Laravel-Specific Debugging Tips

### Debug Controllers
```php
// Set breakpoints in controller methods
public function getTodos()
{
    // Breakpoint here
    $todos = Todo::all();
    return response()->json($todos);
}
```

### Debug Blade Templates
- Set breakpoints directly in .blade.php files
- Debug template logic and variables

### Debug API Routes
- Perfect for debugging REST API endpoints
- Inspect request data and responses

### Debug Middleware
- Set breakpoints in middleware files
- Debug authentication, CORS, etc.

### Debug Artisan Commands
```bash
# Debug custom artisan commands
php artisan your:command --debug
```

## Advanced Features

### Watch Expressions
- Add expressions to watch their values
- Right-click > Add to Watch

### Call Stack
- See function call hierarchy
- Click to navigate to different stack levels

### Debug Console
- Evaluate PHP expressions during debugging
- Type PHP code and see results

### Conditional Breakpoints
- Right-click breakpoint > Edit Breakpoint
- Add conditions when breakpoint should trigger

## Performance Notes

- Xdebug can slow down PHP execution
- Only enable for development
- Consider using `xdebug.mode=develop` for profiling only
- Disable in production environments

## Testing Your Setup

1. **Quick Test**: Run `php test_xdebug.php` from terminal
2. **Laravel Test**: Visit http://localhost:8000/debug-test
3. **Controller Test**: Set breakpoint in TodoController and visit TODO page
4. **API Test**: Make request to /api/todos with breakpoint set

## Success Indicators

✅ PHP shows Xdebug loaded
✅ VS Code shows "Listening for Xdebug..." in Debug Console  
✅ Breakpoints turn from hollow to solid red circles
✅ Execution stops at breakpoints
✅ Variables panel shows current scope
✅ Call stack shows execution path
