class BloodRequestModel {
  final String id;
  final String patientName;
  final String? relationship;
  final String bloodType;
  final int unitsNeeded;
  final int unitsFulfilled;
  final String urgency;
  final String status;
  final String hospitalName;
  final String? wardNumber;
  final String? notes;
  final double latitude;
  final double longitude;
  final String contactPhone;
  final DateTime createdAt;
  final int matchedCount;

  BloodRequestModel({
    required this.id,
    required this.patientName,
    this.relationship,
    required this.bloodType,
    required this.unitsNeeded,
    required this.unitsFulfilled,
    required this.urgency,
    required this.status,
    required this.hospitalName,
    this.wardNumber,
    this.notes,
    required this.latitude,
    required this.longitude,
    required this.contactPhone,
    required this.createdAt,
    this.matchedCount = 0,
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
      relationship: json['relationship']?.toString(),
      bloodType: json['bloodType']?.toString() ?? '',
      unitsNeeded: (json['unitsNeeded'] as num?)?.toInt() ?? 1,
      unitsFulfilled: (json['unitsFulfilled'] as num?)?.toInt() ?? 0,
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'PENDING',
      hospitalName: json['hospitalName']?.toString() ?? '',
      wardNumber: json['wardNumber']?.toString(),
      notes: json['notes']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 6.9271,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.8612,
      contactPhone: json['contactPhone']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      matchedCount: (json['matchedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DonorMatchModel {
  final String id;
  final String donorId;
  final String donorName;
  final String bloodType;
  final double compatibilityScore;
  final double proximityScore;
  final double reliabilityScore;
  final double totalScore;
  final String status;
  final int? etaMinutes;
  final double? distanceKm;
  final String? contactPhone;
  final String? whyThisDonor;

  DonorMatchModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.bloodType,
    required this.compatibilityScore,
    required this.proximityScore,
    required this.reliabilityScore,
    required this.totalScore,
    required this.status,
    this.etaMinutes,
    this.distanceKm,
    this.contactPhone,
    this.whyThisDonor,
  });

  factory DonorMatchModel.fromJson(Map<String, dynamic> json) {
    return DonorMatchModel(
      id: json['id']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? 'Verified Donor',
      bloodType: json['bloodType']?.toString() ?? '',
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble() ?? 0.0,
      proximityScore: (json['proximityScore'] as num?)?.toDouble() ?? 0.0,
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'NOTIFIED',
      etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      contactPhone: json['contactPhone']?.toString(),
      whyThisDonor: json['whyThisDonor']?.toString(),
    );
  }

  int get matchPercent => (totalScore * 100).clamp(0, 100).toInt();
}
