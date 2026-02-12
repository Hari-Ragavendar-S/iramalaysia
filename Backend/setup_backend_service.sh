#!/bin/bash

# Irama1Asia - Backend Service Setup
# This script sets up FastAPI backend as a systemd service

set -e

echo "═══════════════════════════════════════════════════════"
echo "🚀 Irama1Asia Backend Service Setup"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Get current directory
BACKEND_DIR=$(pwd)
VENV_PATH="$BACKEND_DIR/venv"

echo "📋 Configuration:"
echo "   Backend Directory: $BACKEND_DIR"
echo "   Virtual Environment: $VENV_PATH"
echo ""

# Step 1: Install Python dependencies
echo "📦 Step 1/4: Installing Python dependencies..."
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install -r requirements.txt -q

# Step 2: Create systemd service
echo "⚙️  Step 2/4: Creating systemd service..."
cat > /etc/systemd/system/irama1asia.service << EOF
[Unit]
Description=Irama1Asia FastAPI Backend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$BACKEND_DIR
Environment="PATH=$VENV_PATH/bin"
ExecStart=$VENV_PATH/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8000 --workers 4
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Step 3: Enable and start service
echo "🚀 Step 3/4: Starting backend service..."
systemctl daemon-reload
systemctl enable irama1asia
systemctl start irama1asia

# Wait for service to start
sleep 3

# Step 4: Check service status
echo "✅ Step 4/4: Checking service status..."
systemctl status irama1asia --no-pager

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅ Backend Service Setup Complete!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📋 Service Commands:"
echo "   Start:   systemctl start irama1asia"
echo "   Stop:    systemctl stop irama1asia"
echo "   Restart: systemctl restart irama1asia"
echo "   Status:  systemctl status irama1asia"
echo "   Logs:    journalctl -u irama1asia -f"
echo ""
echo "🧪 Test Backend:"
echo "   curl http://127.0.0.1:8000/health"
echo ""
echo "═══════════════════════════════════════════════════════"
