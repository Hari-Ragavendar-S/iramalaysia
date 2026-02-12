class AdminUser {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.permissions,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'admin',
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      lastLogin: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'permissions': permissions,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  AdminUser copyWith({String? status}) {
    return AdminUser(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      permissions: permissions,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLogin: lastLogin,
    );
  }

  bool hasPermission(String permission) {
    return role == 'super_admin' || permissions.contains(permission);
  }
}

class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int totalBuskers;
  final int activeBuskers;
  final int totalBookings;
  final double totalRevenue;
  final int totalEvents;
  final int publishedEvents;

  DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalBuskers,
    required this.activeBuskers,
    required this.totalBookings,
    required this.totalRevenue,
    required this.totalEvents,
    required this.publishedEvents,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      totalBuskers: json['total_buskers'] ?? 0,
      activeBuskers: json['active_buskers'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      totalEvents: json['total_events'] ?? 0,
      publishedEvents: json['published_events'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'total_buskers': totalBuskers,
      'active_buskers': activeBuskers,
      'total_bookings': totalBookings,
      'total_revenue': totalRevenue,
      'total_events': totalEvents,
      'published_events': publishedEvents,
    };
  }
}

class BookingVerificationRequest {
  final String status;
  final String? notes;

  BookingVerificationRequest({
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'notes': notes,
    };
  }
}

class BuskerVerificationRequest {
  final String status;
  final String? notes;

  BuskerVerificationRequest({
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'notes': notes,
    };
  }
}

class UserActionRequest {
  final String action;
  final String? reason;

  UserActionRequest({
    required this.action,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'reason': reason,
    };
  }
}

class AdminCreateRequest {
  final String email;
  final String password;
  final String fullName;
  final String role;
  final List<String>? permissions;

  AdminCreateRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.role = 'admin',
    this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role,
      'permissions': permissions,
    };
  }
}

class AdminUpdateRequest {
  final String? fullName;
  final String? role;
  final List<String>? permissions;
  final bool? isActive;

  AdminUpdateRequest({
    this.fullName,
    this.role,
    this.permissions,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['full_name'] = fullName;
    if (role != null) data['role'] = role;
    if (permissions != null) data['permissions'] = permissions;
    if (isActive != null) data['is_active'] = isActive;
    return data;
  }
}

enum AdminRole {
  superAdmin,
  admin,
  moderator;

  static AdminRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'moderator':
        return AdminRole.moderator;
      default:
        return AdminRole.admin;
    }
  }

  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.admin:
        return 'admin';
      case AdminRole.moderator:
        return 'moderator';
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.moderator:
        return 'Moderator';
    }
  }
}

class AdminPermissions {
  static const String usersRead = 'users.read';
  static const String usersWrite = 'users.write';
  static const String usersDelete = 'users.delete';
  
  static const String buskersRead = 'buskers.read';
  static const String buskersWrite = 'buskers.write';
  static const String buskersDelete = 'buskers.delete';
  static const String buskersVerify = 'buskers.verify';
  
  static const String bookingsRead = 'bookings.read';
  static const String bookingsWrite = 'bookings.write';
  static const String bookingsDelete = 'bookings.delete';
  static const String bookingsVerify = 'bookings.verify';
  
  static const String eventsRead = 'events.read';
  static const String eventsWrite = 'events.write';
  static const String eventsDelete = 'events.delete';
  static const String eventsPublish = 'events.publish';
  
  static const String podsRead = 'pods.read';
  static const String podsWrite = 'pods.write';
  static const String podsDelete = 'pods.delete';
  
  static const String adminsRead = 'admins.read';
  static const String adminsWrite = 'admins.write';
  static const String adminsDelete = 'admins.delete';
  
  static const String analyticsRead = 'analytics.read';
  static const String systemManage = 'system.manage';

  static List<String> get allPermissions => [
    usersRead, usersWrite, usersDelete,
    buskersRead, buskersWrite, buskersDelete, buskersVerify,
    bookingsRead, bookingsWrite, bookingsDelete, bookingsVerify,
    eventsRead, eventsWrite, eventsDelete, eventsPublish,
    podsRead, podsWrite, podsDelete,
    adminsRead, adminsWrite, adminsDelete,
    analyticsRead, systemManage,
  ];

  static Map<String, List<String>> get permissionGroups => {
    'Users': [usersRead, usersWrite, usersDelete],
    'Buskers': [buskersRead, buskersWrite, buskersDelete, buskersVerify],
    'Bookings': [bookingsRead, bookingsWrite, bookingsDelete, bookingsVerify],
    'Events': [eventsRead, eventsWrite, eventsDelete, eventsPublish],
    'Pods': [podsRead, podsWrite, podsDelete],
    'Admins': [adminsRead, adminsWrite, adminsDelete],
    'System': [analyticsRead, systemManage],
  };
}

class AdminBooking {
  final String id;
  final String bookingReference;
  final String podId;
  final String podName;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime bookingDate;
  final List<String> timeSlots;
  final double totalAmount;
  final String status;
  final String? paymentProofUrl;
  final DateTime? paymentUploadedAt;
  final DateTime? paymentVerifiedAt;
  final DateTime createdAt;

  AdminBooking({
    required this.id,
    required this.bookingReference,
    required this.podId,
    required this.podName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bookingDate,
    required this.timeSlots,
    required this.totalAmount,
    required this.status,
    this.paymentProofUrl,
    this.paymentUploadedAt,
    this.paymentVerifiedAt,
    required this.createdAt,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      id: json['id'] ?? '',
      bookingReference: json['booking_reference'] ?? '',
      podId: json['pod_id'] ?? '',
      podName: json['pod_name'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      bookingDate: DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      timeSlots: List<String>.from(json['time_slots'] ?? []),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentProofUrl: json['payment_proof_url'],
      paymentUploadedAt: json['payment_uploaded_at'] != null 
          ? DateTime.tryParse(json['payment_uploaded_at']) 
          : null,
      paymentVerifiedAt: json['payment_verified_at'] != null 
          ? DateTime.tryParse(json['payment_verified_at']) 
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'pod_id': podId,
      'pod_name': podName,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'booking_date': bookingDate.toIso8601String(),
      'time_slots': timeSlots,
      'total_amount': totalAmount,
      'status': status,
      'payment_proof_url': paymentProofUrl,
      'payment_uploaded_at': paymentUploadedAt?.toIso8601String(),
      'payment_verified_at': paymentVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdminBooking copyWith({String? status}) {
    return AdminBooking(
      id: id,
      bookingReference: bookingReference,
      podId: podId,
      podName: podName,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      bookingDate: bookingDate,
      timeSlots: timeSlots,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentProofUrl: paymentProofUrl,
      paymentUploadedAt: paymentUploadedAt,
      paymentVerifiedAt: paymentVerifiedAt,
      createdAt: createdAt,
    );
  }
}

class AdminBusker {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String verificationStatus;
  final String? idProofUrl;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final DateTime createdAt;

  AdminBusker({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.verificationStatus,
    this.idProofUrl,
    this.verifiedAt,
    this.verifiedBy,
    required this.createdAt,
  });

  factory AdminBusker.fromJson(Map<String, dynamic> json) {
    return AdminBusker(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      verificationStatus: json['verification_status'] ?? 'pending',
      idProofUrl: json['id_proof_url'],
      verifiedAt: json['verified_at'] != null 
          ? DateTime.tryParse(json['verified_at']) 
          : null,
      verifiedBy: json['verified_by'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'verification_status': verificationStatus,
      'id_proof_url': idProofUrl,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdminBusker copyWith({String? verificationStatus}) {
    return AdminBusker(
      id: id,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idProofUrl: idProofUrl,
      verifiedAt: verifiedAt,
      verifiedBy: verifiedBy,
      createdAt: createdAt,
    );
  }
}

class AdminPod {
  final String id;
  final String name;
  final String description;
  final String location;
  final double basePrice;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;

  AdminPod({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.basePrice,
    required this.features,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminPod.fromJson(Map<String, dynamic> json) {
    return AdminPod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      basePrice: (json['base_price'] ?? 0.0).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'base_price': basePrice,
      'features': features,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AdminEvent {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final double ticketPrice;
  final int maxCapacity;
  final bool isPublished;
  final DateTime createdAt;

  AdminEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.ticketPrice,
    required this.maxCapacity,
    required this.isPublished,
    required this.createdAt,
  });

  factory AdminEvent.fromJson(Map<String, dynamic> json) {
    return AdminEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      ticketPrice: (json['ticket_price'] ?? 0.0).toDouble(),
      maxCapacity: json['max_capacity'] ?? 0,
      isPublished: json['is_published'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'ticket_price': ticketPrice,
      'max_capacity': maxCapacity,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AdminDashboardStats {
  final int totalUsers;
  final int totalBuskers;
  final int totalBookings;
  final int pendingBookings;
  final int verifiedBookings;
  final double totalRevenue;
  final int activePods;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalBuskers,
    required this.totalBookings,
    required this.pendingBookings,
    required this.verifiedBookings,
    required this.totalRevenue,
    required this.activePods,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['total_users'] ?? 0,
      totalBuskers: json['total_buskers'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      pendingBookings: json['pending_bookings'] ?? 0,
      verifiedBookings: json['verified_bookings'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      activePods: json['active_pods'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_buskers': totalBuskers,
      'total_bookings': totalBookings,
      'pending_bookings': pendingBookings,
      'verified_bookings': verifiedBookings,
      'total_revenue': totalRevenue,
      'active_pods': activePods,
    };
  }
}

// Request Classes
class VerifyBookingRequest {
  final String bookingId;
  final String status;
  final String? notes;

  VerifyBookingRequest({
    required this.bookingId,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'status': status,
      'notes': notes,
    };
  }
}

class VerifyBuskerRequest {
  final String buskerId;
  final String status;
  final String? notes;

  VerifyBuskerRequest({
    required this.buskerId,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'busker_id': buskerId,
      'status': status,
      'notes': notes,
    };
  }
}

class CreateAdminRequest {
  final String email;
  final String fullName;
  final String password;
  final String role;
  final List<String> permissions;

  CreateAdminRequest({
    required this.email,
    required this.fullName,
    required this.password,
    required this.role,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'password': password,
      'role': role,
      'permissions': permissions,
    };
  }
}

class UpdateAdminRequest {
  final String adminId;
  final String? fullName;
  final String? role;
  final List<String>? permissions;
  final bool? isActive;

  UpdateAdminRequest({
    required this.adminId,
    this.fullName,
    this.role,
    this.permissions,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'full_name': fullName,
      'role': role,
      'permissions': permissions,
      'is_active': isActive,
    };
  }
}

class CreatePodRequest {
  final String name;
  final String description;
  final String location;
  final double basePrice;
  final List<String> features;

  CreatePodRequest({
    required this.name,
    required this.description,
    required this.location,
    required this.basePrice,
    required this.features,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'base_price': basePrice,
      'features': features,
    };
  }
}

class UpdatePodRequest {
  final String podId;
  final String? name;
  final String? description;
  final String? location;
  final double? basePrice;
  final List<String>? features;
  final bool? isActive;

  UpdatePodRequest({
    required this.podId,
    this.name,
    this.description,
    this.location,
    this.basePrice,
    this.features,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'pod_id': podId,
      'name': name,
      'description': description,
      'location': location,
      'base_price': basePrice,
      'features': features,
      'is_active': isActive,
    };
  }
}

class CreateEventRequest {
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final double ticketPrice;
  final int maxCapacity;

  CreateEventRequest({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.ticketPrice,
    required this.maxCapacity,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'ticket_price': ticketPrice,
      'max_capacity': maxCapacity,
    };
  }
}

class UpdateEventRequest {
  final String eventId;
  final String? title;
  final String? description;
  final DateTime? eventDate;
  final String? location;
  final double? ticketPrice;
  final int? maxCapacity;
  final bool? isPublished;

  UpdateEventRequest({
    required this.eventId,
    this.title,
    this.description,
    this.eventDate,
    this.location,
    this.ticketPrice,
    this.maxCapacity,
    this.isPublished,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'description': description,
      'event_date': eventDate?.toIso8601String(),
      'location': location,
      'ticket_price': ticketPrice,
      'max_capacity': maxCapacity,
      'is_published': isPublished,
    };
  }
}