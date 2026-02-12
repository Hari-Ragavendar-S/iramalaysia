import '../user/user_models.dart';

class BuskerProfile {
  final String id;
  final String userId;
  final String? stageName;
  final String? bio;
  final List<String> genres;
  final int? experienceYears;
  final String? idProofUrl;
  final String? idProofType;
  final String verificationStatus;
  final String? verificationNotes;
  final int totalShows;
  final double averageRating;
  final List<String> citiesPerformed;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  BuskerProfile({
    required this.id,
    required this.userId,
    this.stageName,
    this.bio,
    required this.genres,
    this.experienceYears,
    this.idProofUrl,
    this.idProofType,
    required this.verificationStatus,
    this.verificationNotes,
    required this.totalShows,
    required this.averageRating,
    required this.citiesPerformed,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  // Convenience getters for admin repository compatibility
  String get email => user?.email ?? '';
  String get fullName => user?.fullName ?? stageName ?? '';
  String get phoneNumber => user?.phone ?? '';
  DateTime? get verifiedAt => null; // Would need to be added to backend
  String? get verifiedBy => null; // Would need to be added to backend

  factory BuskerProfile.fromJson(Map<String, dynamic> json) {
    return BuskerProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      stageName: json['stage_name'],
      bio: json['bio'],
      genres: List<String>.from(json['genres'] ?? []),
      experienceYears: json['experience_years'],
      idProofUrl: json['id_proof_url'],
      idProofType: json['id_proof_type'],
      verificationStatus: json['verification_status'] ?? 'pending',
      verificationNotes: json['verification_notes'],
      totalShows: json['total_shows'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      citiesPerformed: List<String>.from(json['cities_performed'] ?? []),
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'stage_name': stageName,
      'bio': bio,
      'genres': genres,
      'experience_years': experienceYears,
      'id_proof_url': idProofUrl,
      'id_proof_type': idProofType,
      'verification_status': verificationStatus,
      'verification_notes': verificationNotes,
      'total_shows': totalShows,
      'average_rating': averageRating,
      'cities_performed': citiesPerformed,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}

class BuskerRegisterRequest {
  final String? stageName;
  final String? bio;
  final List<String>? genres;
  final int? experienceYears;
  final List<String>? citiesPerformed;

  BuskerRegisterRequest({
    this.stageName,
    this.bio,
    this.genres,
    this.experienceYears,
    this.citiesPerformed,
  });

  Map<String, dynamic> toJson() {
    return {
      'stage_name': stageName,
      'bio': bio,
      'genres': genres,
      'experience_years': experienceYears,
      'cities_performed': citiesPerformed,
    };
  }
}

class BuskerUpdateRequest {
  final String? stageName;
  final String? bio;
  final List<String>? genres;
  final int? experienceYears;
  final List<String>? citiesPerformed;
  final bool? isAvailable;

  BuskerUpdateRequest({
    this.stageName,
    this.bio,
    this.genres,
    this.experienceYears,
    this.citiesPerformed,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (stageName != null) data['stage_name'] = stageName;
    if (bio != null) data['bio'] = bio;
    if (genres != null) data['genres'] = genres;
    if (experienceYears != null) data['experience_years'] = experienceYears;
    if (citiesPerformed != null) data['cities_performed'] = citiesPerformed;
    if (isAvailable != null) data['is_available'] = isAvailable;
    return data;
  }
}

class IdProofUploadRequest {
  final String idProofType;

  IdProofUploadRequest({required this.idProofType});

  Map<String, dynamic> toJson() {
    return {
      'id_proof_type': idProofType,
    };
  }
}

class VerificationStatus {
  final String verificationStatus;
  final String? verificationNotes;

  VerificationStatus({
    required this.verificationStatus,
    this.verificationNotes,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      verificationStatus: json['verification_status'] ?? 'pending',
      verificationNotes: json['verification_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verification_status': verificationStatus,
      'verification_notes': verificationNotes,
    };
  }
}

enum BuskerVerificationStatus {
  pending,
  approved,
  rejected;

  static BuskerVerificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return BuskerVerificationStatus.approved;
      case 'rejected':
        return BuskerVerificationStatus.rejected;
      default:
        return BuskerVerificationStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case BuskerVerificationStatus.pending:
        return 'Pending';
      case BuskerVerificationStatus.approved:
        return 'Approved';
      case BuskerVerificationStatus.rejected:
        return 'Rejected';
    }
  }
}

enum IdProofType {
  ic,
  passport,
  drivingLicense;

  static IdProofType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'passport':
        return IdProofType.passport;
      case 'driving_license':
        return IdProofType.drivingLicense;
      default:
        return IdProofType.ic;
    }
  }

  String get value {
    switch (this) {
      case IdProofType.ic:
        return 'ic';
      case IdProofType.passport:
        return 'passport';
      case IdProofType.drivingLicense:
        return 'driving_license';
    }
  }

  String get displayName {
    switch (this) {
      case IdProofType.ic:
        return 'IC';
      case IdProofType.passport:
        return 'Passport';
      case IdProofType.drivingLicense:
        return 'Driving License';
    }
  }
}