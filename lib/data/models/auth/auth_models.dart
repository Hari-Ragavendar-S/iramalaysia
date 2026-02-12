class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String userType;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    this.userType = 'user',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 1800,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}

class UserProfile {
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

  UserProfile({
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
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
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
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordRequest {
  final String email;
  final String otpCode;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
      'new_password': newPassword,
    };
  }
}

class OtpRequest {
  final String? email;
  final String? phone;
  final String otpCode;
  final String otpType;

  OtpRequest({
    this.email,
    this.phone,
    required this.otpCode,
    required this.otpType,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'otp_code': otpCode,
      'otp_type': otpType,
    };
  }
}

class ResendOtpRequest {
  final String? email;
  final String? phone;
  final String otpType;

  ResendOtpRequest({
    this.email,
    this.phone,
    required this.otpType,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'otp_type': otpType,
    };
  }
}