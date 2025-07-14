@echo off
setlocal enabledelayedexpansion

:: Orderly Setup Script for Windows
:: Automates the initial setup process for new installations

echo.
echo ╔══════════════════════════════════════════╗
echo ║          Orderly Setup Script            ║
echo ║     Inventory Management System          ║
echo ╚══════════════════════════════════════════╝
echo.

:: Check if Python is installed
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8 or higher from https://python.org
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [INFO] Found Python %PYTHON_VERSION%

:: Check if pip is available
echo [INFO] Checking pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip is not available
    echo Please ensure pip is installed with Python
    pause
    exit /b 1
)
echo [INFO] pip is available ✓

:: Create virtual environment
echo [INFO] Creating virtual environment...
if not exist "venv" (
    python -m venv venv
    echo [INFO] Virtual environment created ✓
) else (
    echo [WARNING] Virtual environment already exists
)

:: Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
)
echo [INFO] Virtual environment activated ✓

:: Upgrade pip
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

:: Install dependencies
echo [INFO] Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [INFO] Dependencies installed ✓

:: Setup environment configuration
echo [INFO] Setting up environment configuration...
if not exist ".env" (
    copy .env.example .env >nul
    echo [INFO] Environment file created from template
    echo [WARNING] Please review and update .env file with your configuration
) else (
    echo [WARNING] .env file already exists
)

:: Create necessary directories
echo [INFO] Creating necessary directories...
if not exist "instance" mkdir instance
if not exist "logs" mkdir logs
if not exist "backups" mkdir backups
if not exist "uploads" mkdir uploads
echo [INFO] Directories created ✓

:: Setup database
echo [INFO] Setting up database...
if not exist "migrations" (
    flask db init
    echo [INFO] Database migrations initialized ✓
)

flask db upgrade
if errorlevel 1 (
    echo [ERROR] Failed to run database migrations
    pause
    exit /b 1
)
echo [INFO] Database migrations applied ✓

:: Display completion message
echo.
echo ════════════════════════════════════════════════════════
echo                     Setup Complete!
echo ════════════════════════════════════════════════════════
echo.
echo Next Steps:
echo.
echo 1. Review and update configuration:
echo    notepad .env
echo.
echo 2. Start the application:
echo    python run.py
echo.
echo 3. Open your browser to:
echo    http://localhost:5000
echo.
echo 4. Login with default credentials:
echo    Username: admin
echo    Password: adminpass
echo    ⚠️ Change the default password immediately!
echo.
echo Optional Enhancements:
echo • Install Redis for better performance
echo • Configure PostgreSQL for production
echo • Set up SSL certificates
echo • Configure email settings for reports
echo.
echo Documentation:
echo • README.md - Complete setup guide
echo.
echo Thank you for using Orderly!
echo.
pause
