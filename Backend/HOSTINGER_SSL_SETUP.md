# 🔒 SSL Setup Guide for Hostinger VPS - Irama1Asia Backend

## Complete SSL Configuration for FastAPI on Hostinger

---

## 📋 Prerequisites

Before starting, ensure you have:
- ✅ Hostinger VPS with root access
- ✅ Domain name pointing to your VPS IP
- ✅ Backend uploaded to VPS
- ✅ Python 3.8+ installed
- ✅ Port 80 and 443 open in firewall

---

## 🎯 Quick Setup (Recommended)

### Step 1: Connect to Your Hostinger VPS

```bash
ssh root@your-vps-ip
# Or use Hostinger's web terminal
```

### Step 2: Update Your Domain DNS

In your domain registrar (or Hostinger DNS panel):
```
Type: A Record
Name: @ (or your subdomain)
Value: YOUR_VPS_IP
TTL: 3600
```

Example:
```
api.irama1asia.com → 148.135.138.145
```

### Step 3: Run Automated SSL Setup Script

```bash
cd /root/irama1asia/Backend
chmod +x setup_ssl_hostinger.sh
./setup_ssl_hostinger.sh
```

---

## 📝 Manual Setup (Step by Step)

### 1. Install Required Packages

```bash
# Update system
apt update && apt upgrade -y

# Install Nginx
apt install nginx -y

# Install Certbot for Let's Encrypt
apt install certbot python3-certbot-nginx -y

# Install Python dependencies
apt install python3-pip python3-venv -y
```

### 2. Configure Firewall

```bash
# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8000/tcp  # For direct FastAPI access (optional)

# Enable firewall
ufw enable

# Check status
ufw status
```

### 3. Set Up Your Domain

Make sure your domain points to your VPS IP:
```bash
# Test DNS resolution
nslookup your-domain.com
ping your-domain.com
```

### 4. Configure Nginx as Reverse Proxy

Create Nginx configuration:
```bash
nano /etc/nginx/sites-available/irama1asia
```

Paste this configuration:
```nginx
# HTTP - Redirect to HTTPS
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Let's Encrypt verification
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS - Main configuration
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL certificates (will be added by Certbot)
    # ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Max upload size
    client_max_body_size 10M;
    
    # Proxy to FastAPI backend
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files (uploads)
    location /uploads {
        alias /root/irama1asia/Backend/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # API Documentation
    location /api/v1/docs {
        proxy_pass http://127.0.0.1:8000/api/v1/docs;
        proxy_set_header Host $host;
    }
}
```

### 5. Enable Nginx Configuration

```bash
# Create symbolic link
ln -s /etc/nginx/sites-available/irama1asia /etc/nginx/sites-enabled/

# Remove default configuration
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx
```

### 6. Obtain SSL Certificate with Certbot

```bash
# Get SSL certificate (interactive)
certbot --nginx -d your-domain.com -d www.your-domain.com

# Or non-interactive
certbot --nginx -d your-domain.com -d www.your-domain.com \
  --non-interactive --agree-tos --email your-email@example.com
```

Follow the prompts:
- Enter your email
- Agree to terms
- Choose to redirect HTTP to HTTPS (recommended)

### 7. Set Up Auto-Renewal

```bash
# Test renewal
certbot renew --dry-run

# Certbot automatically sets up a cron job
# Check it with:
systemctl status certbot.timer

# Or manually add to crontab
crontab -e
# Add this line:
0 0 * * * certbot renew --quiet
```

### 8. Set Up FastAPI Backend Service

Create systemd service:
```bash
nano /etc/systemd/system/irama1asia.service
```

Paste this configuration:
```ini
[Unit]
Description=Irama1Asia FastAPI Backend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/irama1asia/Backend
Environment="PATH=/root/irama1asia/Backend/venv/bin"
ExecStart=/root/irama1asia/Backend/venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8000 --workers 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
# Reload systemd
systemctl daemon-reload

# Enable service
systemctl enable irama1asia

# Start service
systemctl start irama1asia

# Check status
systemctl status irama1asia

# View logs
journalctl -u irama1asia -f
```

---

## 🚀 Testing Your SSL Setup

### 1. Test HTTPS Connection
```bash
curl https://your-domain.com/health
```

### 2. Test API Endpoint
```bash
curl https://your-domain.com/api/v1/locations/states
```

### 3. Check SSL Certificate
```bash
openssl s_client -connect your-domain.com:443 -servername your-domain.com
```

### 4. Online SSL Test
Visit: https://www.ssllabs.com/ssltest/analyze.html?d=your-domain.com

---

## 🔧 Troubleshooting

### Issue 1: Nginx Won't Start
```bash
# Check configuration
nginx -t

# Check error logs
tail -f /var/log/nginx/error.log

# Check if port 80/443 is in use
netstat -tulpn | grep :80
netstat -tulpn | grep :443
```

### Issue 2: Certbot Fails
```bash
# Check DNS resolution
nslookup your-domain.com

# Ensure port 80 is accessible
curl http://your-domain.com/.well-known/acme-challenge/test

# Check Certbot logs
tail -f /var/log/letsencrypt/letsencrypt.log
```

### Issue 3: Backend Not Responding
```bash
# Check if backend is running
systemctl status irama1asia

# Check backend logs
journalctl -u irama1asia -n 50

# Test backend directly
curl http://127.0.0.1:8000/health

# Restart backend
systemctl restart irama1asia
```

### Issue 4: 502 Bad Gateway
```bash
# Backend not running
systemctl start irama1asia

# Check backend port
netstat -tulpn | grep :8000

# Check Nginx proxy settings
nginx -t
```

### Issue 5: SSL Certificate Not Renewing
```bash
# Test renewal
certbot renew --dry-run

# Force renewal
certbot renew --force-renewal

# Check timer
systemctl status certbot.timer
systemctl restart certbot.timer
```

---

## 📱 Update Flutter App for HTTPS

Once SSL is configured, update your Flutter app:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://your-domain.com/api/v1';
  static const String uploadsUrl = 'https://your-domain.com/uploads';
  
  // ... rest of config
}
```

---

## 🔐 Security Best Practices

### 1. Update Backend Configuration
```python
# Backend/.env
DEBUG=false
CORS_ORIGINS=["https://your-domain.com", "https://www.your-domain.com"]
```

### 2. Enable HTTPS Redirect in FastAPI
```python
# main.py
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

if not settings.DEBUG:
    app.add_middleware(HTTPSRedirectMiddleware)
```

### 3. Secure Cookies
```python
# app/core/config.py
SECURE_COOKIES = True
FORCE_HTTPS = True
```

### 4. Rate Limiting
Already configured in your backend with rate limiting settings.

---

## 📊 Monitoring

### Check Backend Status
```bash
# Service status
systemctl status irama1asia

# Real-time logs
journalctl -u irama1asia -f

# Nginx access logs
tail -f /var/log/nginx/access.log

# Nginx error logs
tail -f /var/log/nginx/error.log
```

### Check SSL Certificate Expiry
```bash
# Check expiry date
certbot certificates

# Or
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates
```

---

## 🔄 Maintenance Commands

### Restart Services
```bash
# Restart backend
systemctl restart irama1asia

# Restart Nginx
systemctl restart nginx

# Restart both
systemctl restart irama1asia nginx
```

### Update Backend Code
```bash
cd /root/irama1asia/Backend
git pull  # If using git
systemctl restart irama1asia
```

### Renew SSL Certificate
```bash
# Automatic (runs via cron)
certbot renew

# Manual
certbot renew --force-renewal
systemctl reload nginx
```

---

## 📞 Support Checklist

Before asking for help, check:
- [ ] Domain DNS is correctly configured
- [ ] Ports 80 and 443 are open
- [ ] Nginx is running: `systemctl status nginx`
- [ ] Backend is running: `systemctl status irama1asia`
- [ ] SSL certificate is valid: `certbot certificates`
- [ ] Can access via HTTP: `curl http://your-domain.com`
- [ ] Can access via HTTPS: `curl https://your-domain.com`

---

## 🎉 Success Indicators

When everything is working:
- ✅ `https://your-domain.com` loads without SSL warnings
- ✅ `https://your-domain.com/health` returns `{"status":"healthy"}`
- ✅ `https://your-domain.com/api/v1/docs` shows API documentation
- ✅ SSL Labs test shows A or A+ rating
- ✅ Backend service is running: `systemctl status irama1asia`
- ✅ Nginx is running: `systemctl status nginx`

---

**Your backend will be accessible at:**
- 🌐 Main API: `https://your-domain.com/api/v1`
- 📚 API Docs: `https://your-domain.com/api/v1/docs`
- 📁 Uploads: `https://your-domain.com/uploads`
- ❤️ Health: `https://your-domain.com/health`

**Last Updated**: $(date)
