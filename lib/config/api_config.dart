class ApiConfig {
  // Backend API Configuration
  static const String baseUrl = 'https://irama1.asia/api/v1';
  static const String uploadsUrl = 'https://irama1.asia/uploads';
  
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  
  // Busker endpoints
  static const String buskerRegister = '/buskers/register';
  static const String buskerProfile = '/buskers/profile';
  static const String buskerUploadId = '/buskers/upload-id-proof';
  
  // Pod endpoints
  static const String pods = '/pods';
  static const String podSearch = '/pods/search';
  static String podDetails(String podId) => '/pods/$podId';
  static String podAvailability(String podId) => '/pods/$podId/availability';
  static const String podBookings = '/pods/bookings';
  static String podBookingDetails(String bookingId) => '/pods/bookings/$bookingId';
  static String cancelBooking(String bookingId) => '/pods/bookings/$bookingId/cancel';
  static String uploadPaymentProof(String bookingId) => '/pods/bookings/$bookingId/payment-proof';
  
  // Location endpoints
  static const String states = '/locations/states';
  static String cities(String state) => '/locations/cities/$state';
  static String locations(String state, String city) => '/locations/locations/$state/$city';
  static const String groupedLocations = '/locations/grouped';
  
  // Event endpoints
  static const String events = '/events';
  static String bookEvent(String eventId) => '/events/$eventId/book';
  static const String myEventBookings = '/events/bookings/my-bookings';
  
  // Upload endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}