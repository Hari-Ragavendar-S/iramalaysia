#!/bin/bash

# Irama1Asia - Automated SSL Setup for Hostinger VPS
# This script sets up SSL certificate and Nginx reverse proxy

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════"
echo "🔒 Irama1Asia SSL Setup for Hostinger VPS"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Get domain name
read -p "Enter your domain name (e.g., api.irama1asia.com): " DOMAIN
read -p "Enter your email for SSL certificate: " EMAIL

echo ""
echo "📋 Configuration:"
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"
echo ""
read -p "Is this correct? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "❌ Setup cancelled"
    exit 1
fi

echo ""
echo "🚀 Starting SSL setup..."
echo ""

# Step 1: Update system
echo "📦 Step 1/8: Updating system packages..."
apt update -qq
apt upgrade -y -qq

# Step 2: Install Nginx
echo "📦 Step 2/8: Installing Nginx..."
apt install nginx -y -qq

# Step 3: Install Certbot
echo "📦 Step 3/8: Installing Certbot..."
apt install certbot python3-certbot-nginx -y -qq

# Step 4: Configure firewall
echo "🔥 Step 4/8: Configuring firewall..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8000/tcp
echo "y" | ufw enable

# Step 5: Create Nginx configuration
echo "⚙️  Step 5/8: Creating Nginx configuration..."
cat > /etc/nginx/sites-available/irama1asia << EOF
# HTTP - Redirect to HTTPS
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Let's Encrypt verification
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# HTTPS - Main configuration
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL certificates (will be added by Certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
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
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files (uploads)
    location /uploads {
        alias $(pwd)/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # API Documentation
    location /api/v1/docs {
        proxy_pass http://127.0.0.1:8000/api/v1/docs;
        proxy_set_header Host \$host;
    }
}
EOF

# Step 6: Enable Nginx configuration
echo "⚙️  Step 6/8: Enabling Nginx configuration..."
ln -sf /etc/nginx/sites-available/irama1asia /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

# Step 7: Obtain SSL certificate
echo "🔒 Step 7/8: Obtaining SSL certificate..."
certbot --nginx -d $DOMAIN -d www.$DOMAIN \
    --non-interactive --agree-tos --email $EMAIL \
    --redirect

# Step 8: Set up auto-renewal
echo "🔄 Step 8/8: Setting up auto-renewal..."
systemctl enable certbot.timer
systemctl start certbot.timer

# Test renewal
certbot renew --dry-run

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅ SSL Setup Complete!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📋 Summary:"
echo "   ✅ Nginx installed and configured"
echo "   ✅ SSL certificate obtained"
echo "   ✅ Auto-renewal enabled"
echo "   ✅ Firewall configured"
echo ""
echo "🌐 Your API is now accessible at:"
echo "   https://$DOMAIN/api/v1"
echo "   https://$DOMAIN/api/v1/docs"
echo ""
echo "🔧 Next Steps:"
echo "   1. Start your FastAPI backend:"
echo "      cd $(pwd)"
echo "      python3 -m venv venv"
echo "      source venv/bin/activate"
echo "      pip install -r requirements.txt"
echo "      python main.py"
echo ""
echo "   2. Or set up as a service:"
echo "      ./setup_backend_service.sh"
echo ""
echo "   3. Test your SSL:"
echo "      curl https://$DOMAIN/health"
echo ""
echo "   4. Update your Flutter app:"
echo "      baseUrl = 'https://$DOMAIN/api/v1'"
echo ""
echo "═══════════════════════════════════════════════════════"
