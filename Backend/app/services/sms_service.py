from twilio.rest import Client
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

# Initialize Twilio client
twilio_client = None
if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN:
    twilio_client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)

async def send_sms(to_phone: str, message: str) -> bool:
    """Send SMS using Twilio"""
    try:
        if not twilio_client:
            logger.warning("Twilio not configured, SMS not sent")
            return False
        
        # Ensure phone number is in international format
        if not to_phone.startswith('+'):
            # Assume Malaysian number if no country code
            to_phone = f"+60{to_phone.lstrip('0')}"
        
        message = twilio_client.messages.create(
            body=message,
            from_=settings.TWILIO_PHONE_NUMBER,
            to=to_phone
        )
        
        logger.info(f"SMS sent successfully to {to_phone}, SID: {message.sid}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send SMS to {to_phone}: {str(e)}")
        return False

async def send_otp_sms(to_phone: str, otp_code: str) -> bool:
    """Send OTP SMS"""
    message = f"Your Irama1Asia verification code is: {otp_code}. This code will expire in 10 minutes."
    return await send_sms(to_phone, message)

async def send_booking_sms(to_phone: str, booking_reference: str, pod_name: str, booking_date: str) -> bool:
    """Send booking confirmation SMS"""
    message = f"Irama1Asia: Your booking {booking_reference} for {pod_name} on {booking_date} is confirmed. Enjoy your performance!"
    return await send_sms(to_phone, message)