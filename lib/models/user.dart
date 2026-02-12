class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String userType;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.userType,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      userType: json['user_type']?.toString() ?? 'user',
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? userType,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class BuskerProfile {
  final String id;
  final String userId;
  final String stageName;
  final String? bio;
  final List<String> genres;
  final List<String> instruments;
  final String? idProofUrl;
  final String? profileImageUrl;
  final String verificationStatus;
  final String? verificationNotes;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BuskerProfile({
    required this.id,
    required this.userId,
    required this.stageName,
    this.bio,
    required this.genres,
    required this.instruments,
    this.idProofUrl,
    this.profileImageUrl,
    this.verificationStatus = 'pending',
    this.verificationNotes,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'stage_name': stageName,
      'bio': bio,
      'genres': genres,
      'instruments': instruments,
      'id_proof_url': idProofUrl,
      'profile_image_url': profileImageUrl,
      'verification_status': verificationStatus,
      'verification_notes': verificationNotes,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BuskerProfile.fromJson(Map<String, dynamic> json) {
    return BuskerProfile(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      stageName: json['stage_name']?.toString() ?? '',
      bio: json['bio']?.toString(),
      genres: List<String>.from(json['genres'] ?? []),
      instruments: List<String>.from(json['instruments'] ?? []),
      idProofUrl: json['id_proof_url']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      verificationStatus: json['verification_status']?.toString() ?? 'pending',
      verificationNotes: json['verification_notes']?.toString(),
      verifiedAt: json['verified_at'] != null 
          ? DateTime.tryParse(json['verified_at'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}