#!/bin/bash
# SSL Setup Script for Irama1Asia Backend
# This script automates SSL certificate installation

set -e

echo "🔒 Irama1Asia SSL Setup Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

# Get domain name
read -p "Enter your domain name (e.g., api.irama1asia.com): " DOMAIN
read -p "Enter your email for SSL notifications: " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo -e "${RED}❌ Domain and email are required${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}📋 Configuration:${NC}"
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"
echo "   Server IP: 148.135.138.145"
echo ""

read -p "Continue with this configuration? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Step 1: Update system
echo ""
echo -e "${YELLOW}📦 Step 1: Updating system packages...${NC}"
apt update
apt upgrade -y

# Step 2: Install Nginx
echo ""
echo -e "${YELLOW}🌐 Step 2: Installing Nginx...${NC}"
apt install -y nginx

# Step 3: Install Certbot
echo ""
echo -e "${YELLOW}🔐 Step 3: Installing Certbot...${NC}"
apt install -y certbot python3-certbot-nginx

# Step 4: Configure firewall
echo ""
echo -e "${YELLOW}🔥 Step 4: Configuring firewall...${NC}"
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

# Step 5: Create Nginx configuration
echo ""
echo -e "${YELLOW}⚙️  Step 5: Creating Nginx configuration...${NC}"

cat > /etc/nginx/sites-available/irama1asia << EOF
# Irama1Asia Backend Configuration

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;
    
    # SSL Configuration (will be added by Certbot)
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy to FastAPI Backend
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
    
    # Increase upload size
    client_max_body_size 10M;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/irama1asia /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo ""
echo -e "${YELLOW}🧪 Testing Nginx configuration...${NC}"
nginx -t

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Nginx configuration test failed${NC}"
    exit 1
fi

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

# Step 6: Obtain SSL Certificate
echo ""
echo -e "${YELLOW}🔐 Step 6: Obtaining SSL certificate from Let's Encrypt...${NC}"
echo -e "${YELLOW}⏳ This may take a few moments...${NC}"

certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SSL certificate obtained successfully!${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed to obtain SSL certificate${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "   1. Domain DNS points to 148.135.138.145"
    echo "   2. Ports 80 and 443 are accessible"
    echo "   3. No other service is using these ports"
    exit 1
fi

# Step 7: Setup auto-renewal
echo ""
echo -e "${YELLOW}🔄 Step 7: Setting up automatic certificate renewal...${NC}"
systemctl enable certbot.timer
systemctl start certbot.timer

# Test renewal
certbot renew --dry-run

# Step 8: Update Backend configuration
echo ""
echo -e "${YELLOW}⚙️  Step 8: Updating backend configuration...${NC}"

# Update .env file
if [ -f ".env" ]; then
    sed -i "s|http://|https://|g" .env
    sed -i "s|FORCE_HTTPS=false|FORCE_HTTPS=true|g" .env
    echo -e "${GREEN}✅ Backend configuration updated${NC}"
fi

# Final summary
echo ""
echo -e "${GREEN}🎉 SSL Setup Complete!${NC}"
echo "================================"
echo ""
echo -e "${GREEN}✅ Nginx installed and configured${NC}"
echo -e "${GREEN}✅ SSL certificate obtained${NC}"
echo -e "${GREEN}✅ Auto-renewal configured${NC}"
echo -e "${GREEN}✅ Firewall configured${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "   1. Start your FastAPI backend:"
echo "      cd $(pwd)"
echo "      python main.py"
echo ""
echo "   2. Access your API:"
echo "      https://$DOMAIN"
echo "      https://$DOMAIN/api/v1/docs"
echo ""
echo "   3. Update Flutter app API URL:"
echo "      baseUrl = 'https://$DOMAIN/api/v1'"
echo ""
echo -e "${YELLOW}🔐 SSL Certificate Info:${NC}"
echo "   Certificate: /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
echo "   Private Key: /etc/letsencrypt/live/$DOMAIN/privkey.pem"
echo "   Expires: $(date -d '+90 days' '+%Y-%m-%d')"
echo "   Auto-renewal: Enabled"
echo ""
echo -e "${YELLOW}📊 Useful Commands:${NC}"
echo "   Check SSL: sudo certbot certificates"
echo "   Renew SSL: sudo certbot renew"
echo "   Nginx logs: sudo tail -f /var/log/nginx/error.log"
echo "   Restart Nginx: sudo systemctl restart nginx"
echo ""
echo -e "${GREEN}Your backend is now secure with HTTPS! 🔒${NC}"