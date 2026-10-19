import 'package:bloodlink_mobile/core/constants/api_constants.dart';
import 'package:bloodlink_mobile/core/network/api_client.dart';
import 'donor_models.dart';

class DonorRepository {
  final ApiClient apiClient;

  DonorRepository({ApiClient? client}) : apiClient = client ?? ApiClient();

  Future<List<AppealModel>> getNearbyAppeals({
    double? lat,
    double? lng,
    double radiusKm = 40.0,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.nearbyAppeals,
      queryParameters: {
        'lat': ?lat,
        'lng': ?lng,
        'radiusKm': radiusKm,
      },
    );

    if (response.data is List) {
      return (response.data as List).map((e) => AppealModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<MatchAlertModel>> getDonorAlerts() async {
    final response = await apiClient.dio.get(ApiConstants.donorAlerts);
    if (response.data is List) {
      return (response.data as List).map((e) => MatchAlertModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> acceptMatch({
    required String matchId,
    required int etaMinutes,
  }) async {
    await apiClient.dio.post(
      '/api/matches/$matchId/accept',
      data: {'etaMinutes': etaMinutes},
    );
  }

  Future<void> declineMatch(String matchId) async {
    await apiClient.dio.post('/api/matches/$matchId/decline');
  }

  Future<EligibilityResultModel> checkEligibility({
    required int age,
    required double weightKg,
    required String gender,
    required int daysSinceLastDonation,
    required bool hasFeverOrInfection,
    required bool takingAntibioticsOrAspirin,
    required bool traveledEndemicMalariaOrDengue,
    required bool hadRecentTattooOrPiercing,
    required bool isPregnantOrNursing,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.eligibilityCheck,
      data: {
        'age': age,
        'weightKg': weightKg,
        'gender': gender,
        'daysSinceLastDonation': daysSinceLastDonation,
        'hasFeverOrInfection': hasFeverOrInfection,
        'takingAntibioticsOrAspirin': takingAntibioticsOrAspirin,
        'traveledEndemicMalariaOrDengue': traveledEndemicMalariaOrDengue,
        'hadRecentTattooOrPiercing': hadRecentTattooOrPiercing,
        'isPregnantOrNursing': isPregnantOrNursing,
      },
    );

    return EligibilityResultModel.fromJson(response.data);
  }

  Future<void> toggleAvailability(bool isAvailable) async {
    await apiClient.dio.put(
      ApiConstants.updateAvailability,
      data: {'isAvailable': isAvailable},
    );
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? district,
    String? city,
  }) async {
    await apiClient.dio.put(
      ApiConstants.updateLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'district': ?district,
        'city': ?city,
      },
    );
  }
}
