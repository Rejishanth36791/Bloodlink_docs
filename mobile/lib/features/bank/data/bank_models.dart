class InventoryItemModel {
  final String bloodType;
  final int unitsAvailable;
  final String status; // SAFE, AMBER, CRITICAL

  InventoryItemModel({
    required this.bloodType,
    required this.unitsAvailable,
    required this.status,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      bloodType: json['bloodType']?.toString() ?? '',
      unitsAvailable: (json['unitsAvailable'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'SAFE',
    );
  }
}

class IncomingDonorModel {
  final String donationId;
  final String donorName;
  final String bloodType;
  final String? timeSlot;
  final String status;

  IncomingDonorModel({
    required this.donationId,
    required this.donorName,
    required this.bloodType,
    this.timeSlot,
    required this.status,
  });

  factory IncomingDonorModel.fromJson(Map<String, dynamic> json) {
    return IncomingDonorModel(
      donationId: json['donationId']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? 'Donor',
      bloodType: json['bloodType']?.toString() ?? '',
      timeSlot: json['timeSlot']?.toString(),
      status: json['status']?.toString() ?? 'SCHEDULED',
    );
  }
}

class DemandForecastModel {
  final String district;
  final String bloodType;
  final int predictedShortageDays;
  final double trendPercent;
  final double confidencePercent;
  final String recommendation;

  DemandForecastModel({
    required this.district,
    required this.bloodType,
    required this.predictedShortageDays,
    required this.trendPercent,
    required this.confidencePercent,
    required this.recommendation,
  });

  factory DemandForecastModel.fromJson(Map<String, dynamic> json) {
    return DemandForecastModel(
      district: json['district']?.toString() ?? 'Western',
      bloodType: json['bloodType']?.toString() ?? 'O-',
      predictedShortageDays: (json['predictedShortageDays'] as num?)?.toInt() ?? 12,
      trendPercent: (json['trendPercent'] as num?)?.toDouble() ?? -18.0,
      confidencePercent: (json['confidencePercent'] as num?)?.toDouble() ?? 96.0,
      recommendation: json['recommendation']?.toString() ??
          'O- negative reserves predicted to drop below safe threshold.',
    );
  }
}

class BankDashboardModel {
  final String bankName;
  final String facilityType;
  final int totalUnits;
  final int dailyQuotaMet;
  final int activeDispatches;
  final List<InventoryItemModel> bloodMatrix;
  final List<IncomingDonorModel> incomingDonors;
  final List<DemandForecastModel> forecasts;

  BankDashboardModel({
    required this.bankName,
    required this.facilityType,
    required this.totalUnits,
    required this.dailyQuotaMet,
    required this.activeDispatches,
    required this.bloodMatrix,
    required this.incomingDonors,
    required this.forecasts,
  });

  factory BankDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawMatrix = json['bloodMatrix'] as List? ?? [];
    final rawDonors = json['incomingDonors'] as List? ?? [];
    final rawForecasts = json['forecasts'] as List? ?? [];

    return BankDashboardModel(
      bankName: json['bankName']?.toString() ?? 'National Blood Transfusion Service',
      facilityType: json['facilityType']?.toString() ?? 'NATIONAL_CENTER',
      totalUnits: (json['totalUnits'] as num?)?.toInt() ?? 0,
      dailyQuotaMet: (json['dailyQuotaMet'] as num?)?.toInt() ?? 0,
      activeDispatches: (json['activeDispatches'] as num?)?.toInt() ?? 0,
      bloodMatrix: rawMatrix.map((e) => InventoryItemModel.fromJson(e)).toList(),
      incomingDonors: rawDonors.map((e) => IncomingDonorModel.fromJson(e)).toList(),
      forecasts: rawForecasts.map((e) => DemandForecastModel.fromJson(e)).toList(),
    );
  }
}

class DonationCampModel {
  final String id;
  final String title;
  final String locationName;
  final String district;
  final String date;
  final String startTime;
  final String endTime;
  final int targetUnits;
  final int registeredCount;

  DonationCampModel({
    required this.id,
    required this.title,
    required this.locationName,
    required this.district,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.targetUnits,
    required this.registeredCount,
  });

  factory DonationCampModel.fromJson(Map<String, dynamic> json) {
    return DonationCampModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      targetUnits: (json['targetUnits'] as num?)?.toInt() ?? 100,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
    );
  }
}
