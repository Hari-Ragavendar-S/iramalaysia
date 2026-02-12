# SSL Certificate Configuration Guide for Irama1Asia Backend

## 🔒 Overview
This guide covers SSL/TLS certificate setup for your FastAPI backend to enable HTTPS connections.

## 📋 Prerequisites
- Domain name pointing to your server (148.135.138.145)
- Root/sudo access to your server
- Port 80 and 443 open in firewall

## 🎯 Recommended Approach: Let's Encrypt (Free SSL)

### Option 1: Using Certbot (Recommended for Production)

#### Step 1: Install Certbot
```bash
# For Ubuntu/Debian
sudo apt update
sudo apt install certbot python3-certbot-nginx

# For CentOS/RHEL
sudo yum install certbot python3-certbot-nginx
```

#### Step 2: Obtain SSL Certificate
```bash
# Replace with your actual domain
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Or if you have Nginx running
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

#### Step 3: Certificate Location
After successful installation, certificates will be at:
```
Certificate: /etc/letsencrypt/live/yourdomain.com/fullchain.pem
Private Key: /etc/letsencrypt/live/yourdomain.com/privkey.pem
```

#### Step 4: Auto-Renewal Setup
```bash
# Test renewal
sudo certbot renew --dry-run

# Certbot automatically sets up auto-renewal via cron/systemd
```

---

## 🚀 FastAPI SSL Configuration

### Method 1: Direct SSL in FastAPI (Development/Testing)

Update `main.py`:

```python
import uvicorn
import ssl

if __name__ == "__main__":
    # SSL Configuration
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain(
        certfile="/etc/letsencrypt/live/yourdomain.com/fullchain.pem",
        keyfile="/etc/letsencrypt/live/yourdomain.com/privkey.pem"
    )
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=443,
        ssl_keyfile="/etc/letsencrypt/live/yourdomain.com/privkey.pem",
        ssl_certfile="/etc/letsencrypt/live/yourdomain.com/fullchain.pem",
        reload=False
    )
```

### Method 2: Nginx Reverse Proxy (Recommended for Production)

#### Step 1: Install Nginx
```bash
sudo apt install nginx
```

#### Step 2: Create Nginx Configuration
Create `/etc/nginx/sites-available/irama1asia`:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy to FastAPI
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
        alias /path/to/your/Backend/uploads;
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

#### Step 3: Enable Configuration
```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/irama1asia /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

#### Step 4: Start FastAPI Backend
```bash
# Run on localhost only (Nginx will proxy)
python main.py
```

---

## 🔧 Option 2: Self-Signed Certificate (Development Only)

### Generate Self-Signed Certificate
```bash
# Create directory for certificates
mkdir -p ssl

# Generate certificate (valid for 365 days)
openssl req -x509 -newkey rsa:4096 -nodes \
  -out ssl/cert.pem \
  -keyout ssl/key.pem \
  -days 365 \
  -subj "/C=MY/ST=Kuala Lumpur/L=Kuala Lumpur/O=Irama1Asia/CN=localhost"
```

### Use in FastAPI
```python
if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=443,
        ssl_keyfile="ssl/key.pem",
        ssl_certfile="ssl/cert.pem"
    )
```

**⚠️ Warning**: Self-signed certificates will show security warnings in browsers and mobile apps.

---

## 🐳 Option 3: Docker with SSL

### docker-compose.yml with SSL
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - ./uploads:/var/www/uploads
    depends_on:
      - backend
    restart: unless-stopped

  backend:
    build: .
    environment:
      - DATABASE_URL=${DATABASE_URL}
    volumes:
      - ./uploads:/app/uploads
    expose:
      - "8000"
    restart: unless-stopped

  certbot:
    image: certbot/certbot
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - /var/www/html:/var/www/html
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
```

---

## 📱 Update Flutter App for HTTPS

### Update API Configuration
```dart
// lib/config/api_config.dart
class ApiConfig {
  // Change from HTTP to HTTPS
  static const String baseUrl = 'https://yourdomain.com/api/v1';
  static const String uploadsUrl = 'https://yourdomain.com/uploads';
  
  // ... rest of config
}
```

### Android Network Security (if using self-signed)
Only for development with self-signed certificates:

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">yourdomain.com</domain>
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </domain-config>
</network-security-config>
```

---

## ✅ Verification Steps

### 1. Test SSL Certificate
```bash
# Check certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check SSL rating
curl -I https://yourdomain.com
```

### 2. Test API Endpoints
```bash
# Health check
curl https://yourdomain.com/health

# API endpoint
curl https://yourdomain.com/api/v1/locations/states
```

### 3. Online SSL Checkers
- https://www.ssllabs.com/ssltest/
- https://www.sslshopper.com/ssl-checker.html

---

## 🔒 Security Best Practices

### 1. Update Backend Configuration
```python
# app/core/config.py
class Settings(BaseSettings):
    # Force HTTPS in production
    FORCE_HTTPS: bool = True
    
    # Update CORS for HTTPS
    CORS_ORIGINS: List[str] = [
        "https://yourdomain.com",
        "https://www.yourdomain.com",
        "https://app.yourdomain.com"
    ]
```

### 2. Add HTTPS Redirect Middleware
```python
# main.py
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

if not settings.DEBUG:
    app.add_middleware(HTTPSRedirectMiddleware)
```

### 3. Update Environment Variables
```bash
# .env
FORCE_HTTPS=true
SECURE_COOKIES=true
```

---

## 🚨 Troubleshooting

### Certificate Not Found
```bash
# Check certificate location
sudo ls -la /etc/letsencrypt/live/yourdomain.com/

# Check permissions
sudo chmod 644 /etc/letsencrypt/live/yourdomain.com/fullchain.pem
sudo chmod 600 /etc/letsencrypt/live/yourdomain.com/privkey.pem
```

### Port 443 Already in Use
```bash
# Check what's using port 443
sudo lsof -i :443

# Stop conflicting service
sudo systemctl stop apache2  # or nginx
```

### Certificate Renewal Failed
```bash
# Manual renewal
sudo certbot renew --force-renewal

# Check renewal timer
sudo systemctl status certbot.timer
```

---

## 📊 Recommended Setup for Production

1. **Domain**: Point your domain to 148.135.138.145
2. **SSL**: Use Let's Encrypt (free, auto-renewing)
3. **Proxy**: Nginx reverse proxy
4. **Backend**: FastAPI on localhost:8000
5. **Firewall**: Allow ports 80, 443 only
6. **Auto-renewal**: Certbot handles this automatically

---

## 🎯 Quick Production Setup Script

```bash
#!/bin/bash
# Quick SSL setup for Irama1Asia

# Install dependencies
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Configure Nginx (use the config above)
sudo nano /etc/nginx/sites-available/irama1asia

# Enable site
sudo ln -s /etc/nginx/sites-available/irama1asia /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Start backend
cd /path/to/Backend
python main.py

echo "✅ SSL configured! Access your API at https://yourdomain.com"
```

---

## 📞 Support

For SSL issues:
1. Check Nginx error logs: `sudo tail -f /var/log/nginx/error.log`
2. Check Certbot logs: `sudo tail -f /var/log/letsencrypt/letsencrypt.log`
3. Verify domain DNS: `nslookup yourdomain.com`
4. Test SSL: `openssl s_client -connect yourdomain.com:443`

Your backend will be secure with HTTPS! 🔒