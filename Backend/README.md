# Irama1Asia FastAPI Backend

A comprehensive FastAPI backend system for the Irama1Asia mobile application, supporting busker pod booking, admin panel management, and real-time features.

## 🚀 Features

- **User Authentication & Authorization** with JWT tokens
- **Admin Panel Management System** with role-based permissions
- **Busker Registration & Verification** system
- **Pod Booking System** with real-time availability
- **Event Management** with ticket booking
- **File Upload & Management** with image compression
- **Email & SMS Notifications** via SMTP and Twilio
- **Real-time Features** with WebSockets and Redis
- **Comprehensive API Documentation** with OpenAPI/Swagger

## 📋 Requirements

- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- SMTP Server (Gmail recommended)
- Twilio Account (for SMS)

## 🛠️ Installation

### 1. Clone and Setup

```bash
cd irama1asia/backend
cp .env.example .env
```

### 2. Configure Environment Variables

Edit `.env` file with your configuration:

```bash
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/irama1asia

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key-change-this-in-production

# Email (Gmail SMTP)
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# SMS (Twilio)
TWILIO_ACCOUNT_SID=your-twilio-account-sid
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=+1234567890

# Admin
DEFAULT_ADMIN_EMAIL=info@techneysoft.net
DEFAULT_ADMIN_PASSWORD=Techneysoft@8940
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Database Setup

```bash
# Create database
createdb irama1asia

# Run migrations
alembic upgrade head
```

### 5. Run the Application

```bash
# Development
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production
uvicorn main:app --host 0.0.0.0 --port 8000
```

## 🐳 Docker Deployment

### 1. Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down
```

### 2. Manual Docker Build

```bash
# Build image
docker build -t irama1asia-api .

# Run container
docker run -d \
  --name irama1asia-api \
  -p 8000:8000 \
  -e DATABASE_URL=postgresql://postgres:password@host.docker.internal:5432/irama1asia \
  irama1asia-api
```

## 📚 API Documentation

Once the server is running, access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/api/v1/docs
- **ReDoc**: http://localhost:8000/api/v1/redoc
- **OpenAPI JSON**: http://localhost:8000/api/v1/openapi.json

## 🔐 Default Admin Credentials

```
Email: info@techneysoft.net
Password: Techneysoft@8940
```

## 📊 API Endpoints Overview

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/admin/auth/login` - Admin login
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/forgot-password` - Password reset

### User Management
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update user profile
- `DELETE /api/v1/users/account` - Delete account

### Busker Management
- `POST /api/v1/buskers/register` - Register as busker
- `GET /api/v1/buskers/profile` - Get busker profile
- `PUT /api/v1/buskers/profile` - Update busker profile
- `POST /api/v1/buskers/upload-id-proof` - Upload ID proof

### Pod Booking
- `GET /api/v1/pods` - List available pods
- `GET /api/v1/pods/search` - Search pods
- `GET /api/v1/pods/{pod_id}` - Get pod details
- `GET /api/v1/pods/{pod_id}/availability` - Check availability
- `POST /api/v1/pods/bookings` - Create booking
- `GET /api/v1/pods/bookings` - Get user bookings

### Event Management
- `GET /api/v1/events` - List published events
- `GET /api/v1/events/search` - Search events
- `GET /api/v1/events/{event_id}` - Get event details
- `POST /api/v1/events/{event_id}/book` - Book event tickets

### Admin Panel
- `GET /api/v1/admin/dashboard/stats` - Dashboard statistics
- `GET /api/v1/admin/users` - Manage users
- `GET /api/v1/admin/buskers` - Manage buskers
- `GET /api/v1/admin/bookings` - Manage bookings
- `POST /api/v1/admin/pods` - Create/manage pods
- `POST /api/v1/admin/events` - Create/manage events
- `GET /api/v1/admin/admins` - Manage admin users

### File Upload
- `POST /api/v1/upload/image` - Upload image
- `POST /api/v1/upload/document` - Upload document
- `GET /api/v1/upload/files/{file_id}` - Get file
- `DELETE /api/v1/upload/files/{file_id}` - Delete file

## 🗄️ Database Schema

The system uses PostgreSQL with the following main tables:

- **users** - User accounts and profiles
- **admin_users** - Admin user accounts with roles
- **buskers** - Busker profiles and verification
- **pods** - Performance pod locations
- **pod_bookings** - Pod booking records
- **events** - Event listings
- **event_bookings** - Event ticket bookings
- **otp_verifications** - OTP codes for verification
- **file_uploads** - File upload records

## 🔧 Configuration

### Email Setup (Gmail)

1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
3. Use the app password in `SMTP_PASSWORD`

### SMS Setup (Twilio)

1. Create a Twilio account
2. Get your Account SID and Auth Token
3. Purchase a phone number
4. Configure in environment variables

### File Upload Configuration

- Images are automatically compressed and optimized
- Supported formats: JPG, JPEG, PNG, WebP
- Maximum file size: 10MB
- Files are stored in `./uploads/` directory

## 🧪 Testing

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest

# Run with coverage
pytest --cov=app tests/
```

## 📈 Monitoring & Logging

The application includes:

- Health check endpoint: `GET /health`
- Structured logging with different levels
- Request/response logging
- Error tracking and reporting
- Performance monitoring

## 🔒 Security Features

- JWT-based authentication with refresh tokens
- Password hashing with bcrypt
- Rate limiting on sensitive endpoints
- Input validation with Pydantic
- SQL injection prevention
- XSS protection
- File upload security with type validation
- Role-based access control for admin functions

## 🚀 Production Deployment

### Environment Setup

1. Use a production-grade WSGI server (Gunicorn + Uvicorn)
2. Set up SSL/TLS certificates
3. Configure reverse proxy (Nginx)
4. Set up database backups
5. Configure monitoring and alerting
6. Use environment-specific configuration

### Performance Optimization

- Enable database connection pooling
- Use Redis for caching and sessions
- Implement CDN for static files
- Enable gzip compression
- Set up database indexing
- Monitor and optimize slow queries

## 📞 Support

For technical support or questions about the backend implementation, please contact the development team.

## 📄 License

This project is proprietary software developed for Irama1Asia.