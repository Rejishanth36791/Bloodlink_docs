import 'package:bloodlink_mobile/core/constants/api_constants.dart';
import 'package:bloodlink_mobile/core/network/api_client.dart';
import 'bank_models.dart';

class BankRepository {
  final ApiClient apiClient;

  BankRepository({ApiClient? client}) : apiClient = client ?? ApiClient();

  Future<BankDashboardModel> getDashboard() async {
    final response = await apiClient.dio.get(ApiConstants.bankDashboard);
    return BankDashboardModel.fromJson(response.data);
  }

  Future<void> adjustInventory({
    required String bloodType,
    required String componentType,
    required int quantityChange,
    required String reason,
    String? batchNumber,
  }) async {
    await apiClient.dio.post(
      ApiConstants.inventoryAdjust,
      data: {
        'bloodType': bloodType,
        'componentType': componentType,
        'quantityChange': quantityChange,
        'reason': reason,
        'batchNumber': ?batchNumber,
      },
    );
  }

  Future<void> verifyDonationArrival({
    required String donationId,
    required int volumeMl,
    required String bloodBagBarcode,
  }) async {
    await apiClient.dio.post(
      '/api/bank/donations/$donationId/verify',
      data: {
        'volumeMl': volumeMl,
        'bloodBagBarcode': bloodBagBarcode,
      },
    );
  }

  Future<List<DonationCampModel>> getNearbyCamps({
    double? lat,
    double? lng,
    double radiusKm = 50.0,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.nearbyCamps,
      queryParameters: {
        'lat': ?lat,
        'lng': ?lng,
        'radiusKm': radiusKm,
      },
    );

    if (response.data is List) {
      return (response.data as List).map((e) => DonationCampModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> rsvpForCamp(String campId) async {
    await apiClient.dio.post('/api/camps/$campId/rsvp');
  }
}
