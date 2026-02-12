@echo off
REM Irama1Asia FastAPI Backend Startup Script for Windows

echo 🚀 Starting Irama1Asia FastAPI Backend...

REM Check if virtual environment exists
if not exist "venv" (
    echo 📦 Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo 📚 Installing dependencies...
pip install -r requirements.txt

REM Check if .env file exists
if not exist ".env" (
    echo ⚙️  Creating .env file from template...
    copy .env.example .env
    echo ⚠️  Please edit .env file with your configuration before running the server!
    pause
    exit /b 1
)

REM Run database setup
echo 🗄️  Setting up database...
python setup.py

REM Start the server
echo 🌟 Starting FastAPI server...
uvicorn main:app --reload --host 0.0.0.0 --port 8000

pause