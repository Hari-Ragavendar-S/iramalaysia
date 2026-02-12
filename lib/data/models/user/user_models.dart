class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String userType;
  final bool isActive;
  final bool isVerified;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.userType,
    required this.isActive,
    required this.isVerified,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      userType: json['user_type'] ?? 'user',
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      profileImageUrl: json['profile_image_url'],
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
      'phone': phone,
      'user_type': userType,
      'is_active': isActive,
      'is_verified': isVerified,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? userType,
    bool? isActive,
    bool? isVerified,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class UpdateUserRequest {
  final String? fullName;
  final String? phone;
  final String? profileImageUrl;

  UpdateUserRequest({
    this.fullName,
    this.phone,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (profileImageUrl != null) data['profile_image_url'] = profileImageUrl;
    return data;
  }
}

class UserListResponse {
  final List<User> users;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  UserListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final usersJson = json['users'] ?? [];
    final users = (usersJson as List)
        .map((user) => User.fromJson(user))
        .toList();

    return UserListResponse(
      users: users,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}