#!/bin/bash

# Irama1Asia FastAPI Backend Startup Script

echo "🚀 Starting Irama1Asia FastAPI Backend..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📚 Installing dependencies..."
pip install -r requirements.txt

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚙️  Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your configuration before running the server!"
    exit 1
fi

# Run database setup
echo "🗄️  Setting up database..."
python setup.py

# Start the server
echo "🌟 Starting FastAPI server..."
uvicorn main:app --reload --host 0.0.0.0 --port 8000