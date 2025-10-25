@echo off
REM Learning Dashboard Server Startup Script (Windows)
REM This script starts a local web server for the learning dashboard

echo ================================================================
echo     Learning Hub - Local Server Startup (Windows)
echo ================================================================
echo.

REM Get the directory where this script is located
cd /d "%~dp0"

echo Current directory: %cd%
echo.

REM Check if Python 3 is available
where python3 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ^✓ Python 3 found. Starting server...
    echo.
    echo ^✓ Server is running at: http://localhost:8000
    echo.
    echo Open your browser and go to:
    echo   - http://localhost:8000
    echo   - Click on index.html
    echo.
    echo Press Ctrl+C to stop the server
    echo.
    echo ================================================================
    echo.
    python3 -m http.server 8000
    goto :end
)

REM Check if Python is available
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ^✓ Python found. Starting server...
    echo.
    echo ^✓ Server is running at: http://localhost:8000
    echo.
    echo Open your browser and go to:
    echo   - http://localhost:8000
    echo   - Click on index.html
    echo.
    echo Press Ctrl+C to stop the server
    echo.
    echo ================================================================
    echo.
    python -m http.server 8000
    goto :end
)

REM If Python not found
echo ^✗ Python not found!
echo.
echo Please install Python or use one of these alternatives:
echo.
echo Option 1: Install Python from python.org
echo.
echo Option 2: Use Node.js (if installed):
echo   - Open Command Prompt here
echo   - Run: npx http-server
echo.
echo Option 3: Use VS Code with Live Server extension
echo   - Open index.html in VS Code
echo   - Right-click and select "Open with Live Server"
echo.

:end
pause
