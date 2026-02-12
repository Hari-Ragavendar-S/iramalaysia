#!/bin/bash

# Irama1Asia - SSL Status Checker
# This script checks the status of SSL certificate and services

echo "═══════════════════════════════════════════════════════"
echo "🔍 Irama1Asia SSL Status Check"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check Nginx status
echo "📊 Nginx Status:"
if systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx is running"
else
    echo "   ❌ Nginx is not running"
fi
echo ""

# Check Backend status
echo "📊 Backend Status:"
if systemctl is-active --quiet irama1asia; then
    echo "   ✅ Backend is running"
else
    echo "   ❌ Backend is not running"
fi
echo ""

# Check SSL certificates
echo "🔒 SSL Certificates:"
if command -v certbot &> /dev/null; then
    certbot certificates 2>/dev/null | grep -A 5 "Certificate Name" || echo "   ⚠️  No certificates found"
else
    echo "   ❌ Certbot not installed"
fi
echo ""

# Check open ports
echo "🔌 Open Ports:"
netstat -tulpn 2>/dev/null | grep -E ":(80|443|8000)" || echo "   ⚠️  No ports found"
echo ""

# Check firewall
echo "🔥 Firewall Status:"
if command -v ufw &> /dev/null; then
    ufw status | grep -E "(80|443|8000)" || echo "   ⚠️  Ports not configured"
else
    echo "   ⚠️  UFW not installed"
fi
echo ""

# Test local backend
echo "🧪 Testing Local Backend:"
if curl -s http://127.0.0.1:8000/health > /dev/null 2>&1; then
    echo "   ✅ Backend responding on localhost"
else
    echo "   ❌ Backend not responding on localhost"
fi
echo ""

# Check Nginx configuration
echo "⚙️  Nginx Configuration:"
if nginx -t 2>&1 | grep -q "successful"; then
    echo "   ✅ Nginx configuration is valid"
else
    echo "   ❌ Nginx configuration has errors"
fi
echo ""

# Check auto-renewal
echo "🔄 SSL Auto-Renewal:"
if systemctl is-active --quiet certbot.timer; then
    echo "   ✅ Auto-renewal is enabled"
    NEXT_RUN=$(systemctl status certbot.timer 2>/dev/null | grep "Trigger:" | awk '{print $2, $3, $4}')
    echo "   Next run: $NEXT_RUN"
else
    echo "   ❌ Auto-renewal is not enabled"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "💡 Useful Commands:"
echo "   View backend logs:  journalctl -u irama1asia -f"
echo "   View nginx logs:    tail -f /var/log/nginx/error.log"
echo "   Restart backend:    systemctl restart irama1asia"
echo "   Restart nginx:      systemctl restart nginx"
echo "   Renew SSL:          certbot renew"
echo "═══════════════════════════════════════════════════════"
