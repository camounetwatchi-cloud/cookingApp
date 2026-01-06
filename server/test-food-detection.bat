@echo off
echo ========================================
echo   Food Detection Test - Gemini 2.5 Flash
echo ========================================
echo.
echo Starting server test...
echo.

cd /d "C:\Users\natha\cookingApp\server"

REM Check if server is running
echo Checking server status...
netstat -an | find "8080" | find "LISTENING" >nul
if %errorlevel% == 0 (
    echo [OK] Server is running on port 8080
    echo.
    echo Running food detection test...
    node test-detection.js
) else (
    echo [!] Server not running on port 8080
    echo.
    echo Starting server...
    start "CookingApp Server" /MIN node index.js
    echo Waiting for server to start...
    timeout /t 3 /nobreak >nul
    echo.
    echo Running food detection test...
    node test-detection.js
)

echo.
echo ========================================
echo Test completed!
echo ========================================
pause
