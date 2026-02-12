# ✅ SSL Setup Checklist - Hostinger VPS

## Complete Step-by-Step Checklist for SSL Configuration

---

## 📋 Pre-Setup Checklist

### Before You Begin
- [ ] Have root access to Hostinger VPS
- [ ] Know your VPS IP address
- [ ] Have a domain name ready
- [ ] Backend files uploaded to VPS
- [ ] Database configured and working

### Domain Configuration
- [ ] Domain purchased/registered
- [ ] DNS A record pointing to VPS IP
- [ ] DNS propagation complete (check: `nslookup your-domain.com`)
- [ ] Can ping domain: `ping your-domain.com`

---

## 🚀 Setup Process

### Phase 1: System Preparation
- [ ] Connected to VPS via SSH
- [ ] System updated: `apt update && apt upgrade -y`
- [ ] Python 3.8+ installed: `python3 --version`
- [ ] Pip installed: `pip3 --version`

### Phase 2: Backend Setup
- [ ] Backend files in `/root/irama1asia/Backend`
- [ ] Virtual environment created: `python3 -m venv venv`
- [ ] Dependencies installed: `pip install -r requirements.txt`
- [ ] Database connection tested
- [ ] Backend runs locally: `python main.py`
- [ ] Health endpoint works: `curl http://127.0.0.1:8000/health`

### Phase 3: Nginx Installation
- [ ] Nginx installed: `apt install nginx -y`
- [ ] Nginx running: `systemctl status nginx`
- [ ] Default page accessible: `curl http://your-vps-ip`

### Phase 4: Firewall Configuration
- [ ] UFW installed: `apt install ufw -y`
- [ ] Port 80 allowed: `ufw allow 80/tcp`
- [ ] Port 443 allowed: `ufw allow 443/tcp`
- [ ] Port 8000 allowed (optional): `ufw allow 8000/tcp`
- [ ] Firewall enabled: `ufw enable`
- [ ] Status checked: `ufw status`

### Phase 5: Nginx Configuration
- [ ] Configuration file created: `/etc/nginx/sites-available/irama1asia`
- [ ] Symbolic link created: `ln -s /etc/nginx/sites-available/irama1asia /etc/nginx/sites-enabled/`
- [ ] Default site removed: `rm /etc/nginx/sites-enabled/default`
- [ ] Configuration tested: `nginx -t`
- [ ] Nginx restarted: `systemctl restart nginx`

### Phase 6: SSL Certificate
- [ ] Certbot installed: `apt install certbot python3-certbot-nginx -y`
- [ ] Domain accessible via HTTP: `curl http://your-domain.com`
- [ ] SSL certificate obtained: `certbot --nginx -d your-domain.com`
- [ ] Certificate files exist: `ls /etc/letsencrypt/live/your-domain.com/`
- [ ] HTTPS works: `curl https://your-domain.com`
- [ ] Auto-renewal enabled: `systemctl status certbot.timer`
- [ ] Renewal tested: `certbot renew --dry-run`

### Phase 7: Backend Service
- [ ] Service file created: `/etc/systemd/system/irama1asia.service`
- [ ] Systemd reloaded: `systemctl daemon-reload`
- [ ] Service enabled: `systemctl enable irama1asia`
- [ ] Service started: `systemctl start irama1asia`
- [ ] Service running: `systemctl status irama1asia`
- [ ] Logs accessible: `journalctl -u irama1asia -f`

### Phase 8: Testing
- [ ] Health endpoint: `curl https://your-domain.com/health`
- [ ] API root: `curl https://your-domain.com/`
- [ ] API docs: `https://your-domain.com/api/v1/docs`
- [ ] Locations endpoint: `curl https://your-domain.com/api/v1/locations/states`
- [ ] SSL Labs test: A or A+ rating
- [ ] No SSL warnings in browser

---

## 🔧 Post-Setup Configuration

### Backend Configuration
- [ ] `.env` file updated with production settings
- [ ] `DEBUG=false` in `.env`
- [ ] CORS origins updated with domain
- [ ] Database connection string correct
- [ ] Admin credentials secured

### Flutter App Update
- [ ] `lib/config/api_config.dart` updated with HTTPS URL
- [ ] `lib/core/constants/app_constants.dart` updated
- [ ] App tested with new backend URL
- [ ] API calls working from app

### Security Hardening
- [ ] SSH key authentication enabled
- [ ] Password authentication disabled
- [ ] Root login disabled (optional)
- [ ] Fail2ban installed (optional)
- [ ] Regular backups configured

---

## 📊 Monitoring Setup

### Service Monitoring
- [ ] Backend service auto-starts on boot
- [ ] Nginx auto-starts on boot
- [ ] SSL auto-renewal working
- [ ] Log rotation configured

### Health Checks
- [ ] Backend health endpoint monitored
- [ ] Nginx status checked regularly
- [ ] SSL expiry monitored
- [ ] Disk space monitored

---

## 🆘 Troubleshooting Checklist

### If Backend Not Accessible
- [ ] Check backend service: `systemctl status irama1asia`
- [ ] Check backend logs: `journalctl -u irama1asia -n 50`
- [ ] Test local backend: `curl http://127.0.0.1:8000/health`
- [ ] Check port 8000: `netstat -tulpn | grep :8000`
- [ ] Restart backend: `systemctl restart irama1asia`

### If Nginx Not Working
- [ ] Check Nginx status: `systemctl status nginx`
- [ ] Test configuration: `nginx -t`
- [ ] Check error logs: `tail -f /var/log/nginx/error.log`
- [ ] Check access logs: `tail -f /var/log/nginx/access.log`
- [ ] Restart Nginx: `systemctl restart nginx`

### If SSL Not Working
- [ ] Check certificate: `certbot certificates`
- [ ] Check certificate files: `ls -la /etc/letsencrypt/live/your-domain.com/`
- [ ] Test renewal: `certbot renew --dry-run`
- [ ] Check Nginx SSL config: `nginx -t`
- [ ] Force renewal: `certbot renew --force-renewal`

### If Domain Not Resolving
- [ ] Check DNS: `nslookup your-domain.com`
- [ ] Check A record: `dig your-domain.com`
- [ ] Wait for DNS propagation (up to 48 hours)
- [ ] Clear DNS cache: `systemd-resolve --flush-caches`

---

## 📝 Maintenance Checklist

### Daily
- [ ] Check backend service status
- [ ] Monitor error logs
- [ ] Check disk space

### Weekly
- [ ] Review access logs
- [ ] Check SSL certificate expiry
- [ ] Test backup restoration

### Monthly
- [ ] Update system packages: `apt update && apt upgrade`
- [ ] Review security logs
- [ ] Test disaster recovery plan
- [ ] Update backend dependencies

---

## 🎯 Success Criteria

Your setup is complete when:
- ✅ `https://your-domain.com/health` returns `{"status":"healthy"}`
- ✅ `https://your-domain.com/api/v1/docs` shows API documentation
- ✅ No SSL warnings in browser
- ✅ SSL Labs test shows A or A+ rating
- ✅ Backend service is active and enabled
- ✅ Nginx is active and enabled
- ✅ SSL auto-renewal is working
- ✅ Flutter app can connect to backend
- ✅ All API endpoints responding correctly
- ✅ File uploads working
- ✅ Database queries working

---

## 📞 Quick Commands Reference

```bash
# Backend
systemctl status irama1asia
systemctl restart irama1asia
journalctl -u irama1asia -f

# Nginx
systemctl status nginx
systemctl restart nginx
nginx -t

# SSL
certbot certificates
certbot renew
certbot renew --dry-run

# Firewall
ufw status
ufw allow 80/tcp
ufw allow 443/tcp

# Testing
curl https://your-domain.com/health
./test_backend.sh
./check_ssl_status.sh

# Logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
journalctl -u irama1asia -f
```

---

## 🎉 Completion

Once all items are checked:
1. Document your setup
2. Save all credentials securely
3. Set up monitoring alerts
4. Create backup schedule
5. Test disaster recovery
6. Update team documentation

**Congratulations! Your backend is now production-ready with SSL! 🚀**

---

**Setup Date**: _______________
**Domain**: _______________
**VPS IP**: _______________
**SSL Expiry**: _______________
**Next Review**: _______________
