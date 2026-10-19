class AppealModel {
  final String id;
  final String bloodType;
  final int unitsNeeded;
  final String urgency;
  final String patientName;
  final String hospitalName;
  final String? district;
  final String? contactPhone;
  final double? distanceKm;
  final int? etaMinutes;
  final DateTime createdAt;

  AppealModel({
    required this.id,
    required this.bloodType,
    required this.unitsNeeded,
    required this.urgency,
    required this.patientName,
    required this.hospitalName,
    this.district,
    this.contactPhone,
    this.distanceKm,
    this.etaMinutes,
    required this.createdAt,
  });

  factory AppealModel.fromJson(Map<String, dynamic> json) {
    return AppealModel(
      id: json['id']?.toString() ?? '',
      bloodType: json['bloodType']?.toString() ?? '',
      unitsNeeded: (json['unitsNeeded'] as num?)?.toInt() ?? 1,
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      patientName: json['patientName']?.toString() ?? 'Patient',
      hospitalName: json['hospitalName']?.toString() ?? 'Hospital',
      district: json['district']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class MatchAlertModel {
  final String id;
  final String requestId;
  final String urgency;
  final String bloodType;
  final int unitsNeeded;
  final String hospitalName;
  final double compatibilityScore;
  final double proximityScore;
  final double reliabilityScore;
  final double totalScore;
  final String status;
  final DateTime createdAt;

  MatchAlertModel({
    required this.id,
    required this.requestId,
    required this.urgency,
    required this.bloodType,
    required this.unitsNeeded,
    required this.hospitalName,
    required this.compatibilityScore,
    required this.proximityScore,
    required this.reliabilityScore,
    required this.totalScore,
    required this.status,
    required this.createdAt,
  });

  factory MatchAlertModel.fromJson(Map<String, dynamic> json) {
    return MatchAlertModel(
      id: json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      bloodType: json['bloodType']?.toString() ?? '',
      unitsNeeded: (json['unitsNeeded'] as num?)?.toInt() ?? 1,
      hospitalName: json['hospitalName']?.toString() ?? '',
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble() ?? 0.0,
      proximityScore: (json['proximityScore'] as num?)?.toDouble() ?? 0.0,
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'NOTIFIED',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class EligibilityResultModel {
  final bool isEligible;
  final double readinessScore;
  final List<String> reasons;
  final String? nextEligibleDate;
  final String modelVersion;
  final double hemoglobinProjection;
  final double weightClearanceKg;
  final int donationCadenceDays;

  EligibilityResultModel({
    required this.isEligible,
    required this.readinessScore,
    required this.reasons,
    this.nextEligibleDate,
    required this.modelVersion,
    this.hemoglobinProjection = 14.2,
    this.weightClearanceKg = 68.0,
    this.donationCadenceDays = 110,
  });

  factory EligibilityResultModel.fromJson(Map<String, dynamic> json) {
    final rawReasons = json['reasons'];
    List<String> parsedReasons = [];
    if (rawReasons is List) {
      parsedReasons = rawReasons.map((e) => e.toString()).toList();
    }

    return EligibilityResultModel(
      isEligible: json['isEligible'] == true,
      readinessScore: (json['readinessScore'] as num?)?.toDouble() ?? 0.0,
      reasons: parsedReasons,
      nextEligibleDate: json['nextEligibleDate']?.toString(),
      modelVersion: json['modelVersion']?.toString() ?? 'NBTS-AI-v1.0',
      hemoglobinProjection: (json['hemoglobinProjection'] as num?)?.toDouble() ?? 14.2,
      weightClearanceKg: (json['weightClearanceKg'] as num?)?.toDouble() ?? 68.0,
      donationCadenceDays: (json['donationCadenceDays'] as num?)?.toInt() ?? 110,
    );
  }
}
