# ⚡ Quick SSL Setup - Hostinger VPS

## 🚀 5-Minute SSL Setup for Irama1Asia Backend

---

## Prerequisites
- ✅ Domain name (e.g., api.irama1asia.com)
- ✅ Domain pointing to your VPS IP
- ✅ SSH access to Hostinger VPS
- ✅ Backend files uploaded to VPS

---

## 🎯 Quick Setup Steps

### 1️⃣ Connect to Your VPS
```bash
ssh root@your-vps-ip
```

### 2️⃣ Navigate to Backend Directory
```bash
cd /root/irama1asia/Backend
# Or wherever you uploaded the backend
```

### 3️⃣ Make Scripts Executable
```bash
chmod +x *.sh
```

### 4️⃣ Run Automated SSL Setup
```bash
./setup_ssl_hostinger.sh
```

**Enter when prompted:**
- Your domain name (e.g., api.irama1asia.com)
- Your email address

### 5️⃣ Set Up Backend Service
```bash
./setup_backend_service.sh
```

### 6️⃣ Test Your Setup
```bash
curl https://your-domain.com/health
```

---

## ✅ That's It!

Your backend is now:
- 🔒 Secured with SSL/HTTPS
- 🚀 Running as a system service
- 🔄 Auto-renewing SSL certificates
- 🌐 Accessible via your domain

---

## 📱 Update Flutter App

```dart
// lib/config/api_config.dart
static const String baseUrl = 'https://your-domain.com/api/v1';
static const String uploadsUrl = 'https://your-domain.com/uploads';
```

---

## 🔧 Useful Commands

```bash
# Check backend status
systemctl status irama1asia

# View backend logs
journalctl -u irama1asia -f

# Restart backend
systemctl restart irama1asia

# Check SSL status
./check_ssl_status.sh

# Check Nginx status
systemctl status nginx

# Restart Nginx
systemctl restart nginx
```

---

## 🆘 Troubleshooting

### Backend not responding?
```bash
systemctl restart irama1asia
journalctl -u irama1asia -n 50
```

### SSL certificate issues?
```bash
certbot certificates
certbot renew --dry-run
```

### Nginx errors?
```bash
nginx -t
tail -f /var/log/nginx/error.log
```

---

## 📞 Need Help?

Run the status checker:
```bash
./check_ssl_status.sh
```

This will show you the status of all services and help identify issues.

---

## 🎉 Success Indicators

When everything works:
- ✅ `https://your-domain.com/health` returns `{"status":"healthy"}`
- ✅ `https://your-domain.com/api/v1/docs` shows API documentation
- ✅ No SSL warnings in browser
- ✅ Backend service is active: `systemctl status irama1asia`

---

**Your API Endpoints:**
- 🌐 Base: `https://your-domain.com/api/v1`
- 📚 Docs: `https://your-domain.com/api/v1/docs`
- ❤️ Health: `https://your-domain.com/health`
