class ApiEndpoints {
  // 🔐 AUTHENTICATION
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authAdminLogin = '/auth/admin/login';
  static const String authRefresh = '/auth/refresh';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResendOtp = '/auth/resend-otp';
  static const String authProfile = '/auth/profile';
  static const String authAdminProfile = '/auth/admin/profile';
  
  // 👤 USERS
  static const String usersProfile = '/users/profile';
  static const String usersAccount = '/users/account';
  
  // 🎤 BUSKERS
  static const String buskersRegister = '/buskers/register';
  static const String buskersUploadIdProof = '/buskers/upload-id-proof';
  static const String buskersProfile = '/buskers/profile';
  static const String buskersVerificationStatus = '/buskers/verification-status';
  
  // 🎧 PODS
  static const String pods = '/pods';
  static const String podsSearch = '/pods/search';
  static String podDetails(String podId) => '/pods/$podId';
  static String podAvailability(String podId) => '/pods/$podId/availability';
  static const String podBookings = '/pods/bookings';
  static const String podBookingsSimple = '/pods/bookings/simple';
  static String podBookingDetails(String bookingId) => '/pods/bookings/$bookingId';
  static String podBookingCancel(String bookingId) => '/pods/bookings/$bookingId/cancel';
  static String podBookingPaymentProof(String bookingId) => '/pods/bookings/$bookingId/payment-proof';
  
  // 🎫 EVENTS
  static const String events = '/events';
  static const String eventsSearch = '/events/search';
  static String eventDetails(String eventId) => '/events/$eventId';
  static String eventBook(String eventId) => '/events/$eventId/book';
  static const String eventsMyBookings = '/events/bookings/my-bookings';
  
  // 🗺 LOCATIONS
  static const String locationsStates = '/locations/states';
  static String locationsCities(String state) => '/locations/cities/$state';
  static String locationsInCity(String state, String city) => '/locations/locations/$state/$city';
  static const String locationsGrouped = '/locations/grouped';
  static String locationDetails(String locationId) => '/locations/$locationId';
  
  // 📤 UPLOAD
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  
  // 💳 PAYMENT PROOF
  static const String paymentProofUpload = '/payment-proof/upload';
  static String paymentProofStatus(String bookingId) => '/payment-proof/booking/$bookingId/status';
  
  // 🛠 ADMIN
  static const String adminDashboardStats = '/admin/dashboard/stats';
  static const String adminBookings = '/admin/bookings';
  static const String adminUsers = '/admin/users';
  static String adminUserDetails(String userId) => '/admin/users/$userId';
  static const String adminBuskers = '/admin/buskers';
  static const String adminBuskersPending = '/admin/buskers/pending';
  static const String adminAdmins = '/admin/admins';
  static const String adminPods = '/admin/pods';
  static const String adminEvents = '/admin/events';
  static String adminBookingVerify(String bookingId) => '/admin/bookings/$bookingId/verify';
  static String adminUserSuspend(String userId) => '/admin/users/$userId/suspend';
  static String adminUserActivate(String userId) => '/admin/users/$userId/activate';
  static String adminBuskerVerify(String buskerId) => '/admin/buskers/$buskerId/verify';
  static String adminPodUpdate(String podId) => '/admin/pods/$podId';
  static String adminEventUpdate(String eventId) => '/admin/events/$eventId';
  static String adminEventPublish(String eventId) => '/admin/events/$eventId/publish';
  static String adminAdminUpdate(String adminId) => '/admin/admins/$adminId';
  static String adminPodDelete(String podId) => '/admin/pods/$podId';
  static String adminAdminDelete(String adminId) => '/admin/admins/$adminId';
}