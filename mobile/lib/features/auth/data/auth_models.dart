class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final String? email;
  final String? phone;
  final String fullName;
  final String role;
  final String status;
  final bool phoneVerified;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 900,
    required this.userId,
    this.email,
    this.phone,
    required this.fullName,
    required this.role,
    required this.status,
    this.phoneVerified = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 900,
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'DONOR',
      status: json['status']?.toString() ?? 'ACTIVE',
      phoneVerified: json['phoneVerified'] == true,
    );
  }
}

class UserProfileModel {
  final String id;
  final String? email;
  final String? phone;
  final String fullName;
  final String role;
  final String status;
  final bool phoneVerified;
  final Map<String, dynamic>? donorProfile;
  final Map<String, dynamic>? requesterProfile;
  final Map<String, dynamic>? bankProfile;

  UserProfileModel({
    required this.id,
    this.email,
    this.phone,
    required this.fullName,
    required this.role,
    required this.status,
    required this.phoneVerified,
    this.donorProfile,
    this.requesterProfile,
    this.bankProfile,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      phoneVerified: json['phoneVerified'] == true,
      donorProfile: json['donorProfile'] as Map<String, dynamic>?,
      requesterProfile: json['requesterProfile'] as Map<String, dynamic>?,
      bankProfile: json['bankProfile'] as Map<String, dynamic>?,
    );
  }
}
