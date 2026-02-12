# Irama1Asia Backend - Supabase PostgreSQL Setup

## 🎯 Overview
This guide helps you connect the Irama1Asia FastAPI backend to your Supabase PostgreSQL database.

## 📋 Prerequisites
- Python 3.8+
- Supabase account with PostgreSQL database
- Database connection string

## 🔧 Configuration

### 1. Database Connection
Your Supabase PostgreSQL connection is already configured:
```
Host: db.ovqpcuapmxmcyvwoeuxb.supabase.co
Port: 5432
Database: postgres
Username: postgres
Password: #Harish_953_
```

### 2. Environment Variables
The `.env` file contains all necessary configuration:
- Database URL with Supabase credentials
- JWT secret keys
- Admin credentials
- CORS settings

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Navigate to backend directory
cd Backend

# Install dependencies
pip install -r requirements.txt

# Run automated setup (tests connection + initializes DB + starts server)
python start_with_supabase.py
```

### Option 2: Manual Setup
```bash
# 1. Test Supabase connection
python test_supabase_connection.py

# 2. Initialize database tables and data
python init_supabase_db.py

# 3. Start the FastAPI server
python main.py
```

## 🔍 Verification Steps

### 1. Test Database Connection
```bash
python test_supabase_connection.py
```
Expected output:
```
✅ PostgreSQL Version: PostgreSQL 15.x
✅ Connected to database: postgres
✅ Connected as user: postgres
✅ Table creation permissions: OK
```

### 2. Initialize Database
```bash
python init_supabase_db.py
```
This will:
- Create all necessary tables
- Insert sample Malaysian locations
- Create default admin user

### 3. Access API
Once running, access:
- **API Docs**: http://148.135.138.145:8000/api/v1/docs
- **Health Check**: http://148.135.138.145:8000/health
- **Admin Login**: Use credentials from `.env` file

## 📊 Database Schema

### Tables Created:
- `users` - User accounts (buskers, admins)
- `locations` - Malaysian venues (states, cities, malls)
- `pods` - Busking pods at each location
- `events` - Busking events and performances
- `bookings` - Pod reservations and payments

### Sample Data Included:
- **13 Malaysian locations** across KL, Selangor, Penang, Johor
- **Default admin user** for system management
- **Location hierarchy** (State → City → Mall/Venue)

## 🔐 Admin Access

### Default Admin Credentials:
- **Email**: info@techneysoft.net
- **Password**: Techneysoft@8940

### Admin Capabilities:
- Manage all users and bookings
- Add/edit locations and pods
- View system analytics
- Handle payment verifications

## 🌐 API Endpoints

### Authentication:
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/refresh` - Token refresh

### Locations:
- `GET /api/v1/locations/states` - Get all states
- `GET /api/v1/locations/cities/{state}` - Get cities in state
- `GET /api/v1/locations/locations/{state}/{city}` - Get venues

### Pods:
- `GET /api/v1/pods` - List all pods
- `POST /api/v1/pods/search` - Search pods with filters
- `GET /api/v1/pods/{pod_id}` - Get pod details

### Bookings:
- `POST /api/v1/pods/bookings` - Create booking
- `GET /api/v1/pods/bookings/my-bookings` - User's bookings
- `POST /api/v1/pods/bookings/{booking_id}/payment-proof` - Upload payment

## 🔧 Troubleshooting

### Connection Issues:
1. **Check Supabase project status** - Ensure it's active
2. **Verify password** - Confirm `#Harish_953_` is correct
3. **Network connectivity** - Test from your server
4. **Firewall settings** - Ensure port 5432 is accessible

### Common Errors:
```bash
# Connection timeout
❌ Error: could not connect to server
🔧 Fix: Check network and Supabase project status

# Authentication failed
❌ Error: password authentication failed
🔧 Fix: Verify password in .env file

# Permission denied
❌ Error: permission denied for schema public
🔧 Fix: Check Supabase user permissions
```

### Database Reset:
If you need to reset the database:
```bash
# Drop all tables (careful!)
python -c "
import asyncio
from app.core.database import drop_db
asyncio.run(drop_db())
"

# Reinitialize
python init_supabase_db.py
```

## 📱 Flutter Integration

### API Base URL:
Update your Flutter app's API configuration:
```dart
static const String baseUrl = 'http://148.135.138.145:8000/api/v1';
```

### Test Endpoints:
- Health: `GET /health`
- States: `GET /api/v1/locations/states`
- Login: `POST /api/v1/auth/login`

## 🎉 Success Indicators

When everything is working correctly:
1. ✅ Connection test passes
2. ✅ Database tables created
3. ✅ Sample data inserted
4. ✅ Admin user created
5. ✅ FastAPI server starts
6. ✅ API docs accessible
7. ✅ Flutter app can connect

## 📞 Support

If you encounter issues:
1. Check the logs for detailed error messages
2. Verify all connection parameters
3. Test with the provided scripts
4. Ensure Supabase project is active and accessible

Your Irama1Asia backend is now connected to Supabase PostgreSQL! 🚀