from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from typing import Dict, Any
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

# Email configuration
conf = ConnectionConfig(
    MAIL_USERNAME=settings.SMTP_USERNAME,
    MAIL_PASSWORD=settings.SMTP_PASSWORD,
    MAIL_FROM=settings.MAIL_FROM,
    MAIL_PORT=settings.SMTP_PORT,
    MAIL_SERVER=settings.SMTP_HOST,
    MAIL_FROM_NAME=settings.MAIL_FROM_NAME,
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True
)

# Email templates
EMAIL_TEMPLATES = {
    "email_verification": {
        "subject": "Verify your Irama1Asia account",
        "body": """
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #FFD700, #FFA500); padding: 20px; text-align: center;">
                <h1 style="color: white; margin: 0;">Irama1Asia</h1>
                <p style="color: white; margin: 5px 0;">Welcome to the Music Community</p>
            </div>
            <div style="padding: 30px; background: #f9f9f9;">
                <h2 style="color: #333;">Hello {name}!</h2>
                <p style="color: #666; line-height: 1.6;">
                    Welcome to Irama1Asia! Please verify your email address to complete your registration.
                </p>
                <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0;">
                    <p style="color: #333; margin: 0;">Your verification code is:</p>
                    <h1 style="color: #FFD700; font-size: 32px; margin: 10px 0; letter-spacing: 5px;">{otp_code}</h1>
                    <p style="color: #666; font-size: 14px;">This code will expire in 10 minutes.</p>
                </div>
                <p style="color: #666; line-height: 1.6;">
                    If you didn't create an account with Irama1Asia, please ignore this email.
                </p>
            </div>
            <div style="background: #333; padding: 20px; text-align: center;">
                <p style="color: #999; margin: 0; font-size: 14px;">
                    © 2024 Irama1Asia. All rights reserved.
                </p>
            </div>
        </body>
        </html>
        """
    },
    "password_reset": {
        "subject": "Reset your Irama1Asia password",
        "body": """
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #FFD700, #FFA500); padding: 20px; text-align: center;">
                <h1 style="color: white; margin: 0;">Irama1Asia</h1>
                <p style="color: white; margin: 5px 0;">Password Reset Request</p>
            </div>
            <div style="padding: 30px; background: #f9f9f9;">
                <h2 style="color: #333;">Hello {name}!</h2>
                <p style="color: #666; line-height: 1.6;">
                    We received a request to reset your password. Use the code below to reset your password.
                </p>
                <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0;">
                    <p style="color: #333; margin: 0;">Your password reset code is:</p>
                    <h1 style="color: #FFD700; font-size: 32px; margin: 10px 0; letter-spacing: 5px;">{otp_code}</h1>
                    <p style="color: #666; font-size: 14px;">This code will expire in 15 minutes.</p>
                </div>
                <p style="color: #666; line-height: 1.6;">
                    If you didn't request a password reset, please ignore this email or contact support if you have concerns.
                </p>
            </div>
            <div style="background: #333; padding: 20px; text-align: center;">
                <p style="color: #999; margin: 0; font-size: 14px;">
                    © 2024 Irama1Asia. All rights reserved.
                </p>
            </div>
        </body>
        </html>
        """
    },
    "booking_confirmation": {
        "subject": "Booking Confirmation - Irama1Asia",
        "body": """
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #FFD700, #FFA500); padding: 20px; text-align: center;">
                <h1 style="color: white; margin: 0;">Irama1Asia</h1>
                <p style="color: white; margin: 5px 0;">Booking Confirmation</p>
            </div>
            <div style="padding: 30px; background: #f9f9f9;">
                <h2 style="color: #333;">Hello {name}!</h2>
                <p style="color: #666; line-height: 1.6;">
                    Your booking has been confirmed! Here are the details:
                </p>
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
                    <h3 style="color: #FFD700; margin-top: 0;">Booking Details</h3>
                    <p><strong>Booking Reference:</strong> {booking_reference}</p>
                    <p><strong>Pod:</strong> {pod_name}</p>
                    <p><strong>Location:</strong> {mall}, {city}</p>
                    <p><strong>Date:</strong> {booking_date}</p>
                    <p><strong>Time Slots:</strong> {time_slots}</p>
                    <p><strong>Total Amount:</strong> RM {total_amount}</p>
                </div>
                <p style="color: #666; line-height: 1.6;">
                    Please arrive 15 minutes before your scheduled time. Have a great performance!
                </p>
            </div>
            <div style="background: #333; padding: 20px; text-align: center;">
                <p style="color: #999; margin: 0; font-size: 14px;">
                    © 2024 Irama1Asia. All rights reserved.
                </p>
            </div>
        </body>
        </html>
        """
    },
    "otp_verification": {
        "subject": "Your Irama1Asia verification code",
        "body": """
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #FFD700, #FFA500); padding: 20px; text-align: center;">
                <h1 style="color: white; margin: 0;">Irama1Asia</h1>
                <p style="color: white; margin: 5px 0;">Verification Code</p>
            </div>
            <div style="padding: 30px; background: #f9f9f9;">
                <h2 style="color: #333;">Hello {name}!</h2>
                <p style="color: #666; line-height: 1.6;">
                    Here is your verification code:
                </p>
                <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0;">
                    <h1 style="color: #FFD700; font-size: 32px; margin: 10px 0; letter-spacing: 5px;">{otp_code}</h1>
                    <p style="color: #666; font-size: 14px;">This code will expire in 10 minutes.</p>
                </div>
            </div>
            <div style="background: #333; padding: 20px; text-align: center;">
                <p style="color: #999; margin: 0; font-size: 14px;">
                    © 2024 Irama1Asia. All rights reserved.
                </p>
            </div>
        </body>
        </html>
        """
    }
}

async def send_email(
    to_email: str,
    subject: str,
    template: str,
    context: Dict[str, Any]
) -> bool:
    """Send email using template"""
    try:
        if template not in EMAIL_TEMPLATES:
            logger.error(f"Email template '{template}' not found")
            return False
        
        template_data = EMAIL_TEMPLATES[template]
        
        # Format email body with context
        body = template_data["body"].format(**context)
        
        message = MessageSchema(
            subject=subject,
            recipients=[to_email],
            body=body,
            subtype=MessageType.html
        )
        
        fm = FastMail(conf)
        await fm.send_message(message)
        
        logger.info(f"Email sent successfully to {to_email}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send email to {to_email}: {str(e)}")
        return False

async def send_bulk_email(
    recipients: list,
    subject: str,
    template: str,
    context: Dict[str, Any]
) -> bool:
    """Send bulk email"""
    try:
        if template not in EMAIL_TEMPLATES:
            logger.error(f"Email template '{template}' not found")
            return False
        
        template_data = EMAIL_TEMPLATES[template]
        body = template_data["body"].format(**context)
        
        message = MessageSchema(
            subject=subject,
            recipients=recipients,
            body=body,
            subtype=MessageType.html
        )
        
        fm = FastMail(conf)
        await fm.send_message(message)
        
        logger.info(f"Bulk email sent successfully to {len(recipients)} recipients")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send bulk email: {str(e)}")
        return False