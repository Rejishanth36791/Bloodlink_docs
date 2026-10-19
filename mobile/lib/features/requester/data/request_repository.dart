import 'package:bloodlink_mobile/core/constants/api_constants.dart';
import 'package:bloodlink_mobile/core/network/api_client.dart';
import 'request_models.dart';

class RequestRepository {
  final ApiClient apiClient;

  RequestRepository({ApiClient? client}) : apiClient = client ?? ApiClient();

  Future<BloodRequestModel> createRequest({
    required String patientName,
    String? relationship,
    required String bloodType,
    required int unitsNeeded,
    required String urgency,
    required String hospitalName,
    String? wardNumber,
    String? notes,
    required double latitude,
    required double longitude,
    required String contactPhone,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.requests,
      data: {
        'patientName': patientName,
        'relationship': ?relationship,
        'bloodType': bloodType,
        'unitsNeeded': unitsNeeded,
        'urgency': urgency,
        'hospitalName': hospitalName,
        'wardNumber': ?wardNumber,
        'notes': ?notes,
        'latitude': latitude,
        'longitude': longitude,
        'contactPhone': contactPhone,
      },
    );

    return BloodRequestModel.fromJson(response.data);
  }

  Future<List<BloodRequestModel>> getMyRequests() async {
    final response = await apiClient.dio.get(ApiConstants.myRequests);
    if (response.data is List) {
      return (response.data as List).map((e) => BloodRequestModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<BloodRequestModel> getRequestById(String id) async {
    final response = await apiClient.dio.get('${ApiConstants.requests}/$id');
    return BloodRequestModel.fromJson(response.data);
  }

  Future<void> cancelRequest(String id) async {
    await apiClient.dio.post('${ApiConstants.requests}/$id/cancel');
  }

  Future<List<DonorMatchModel>> getMatches(String requestId) async {
    final response = await apiClient.dio.get('${ApiConstants.requests}/$requestId/matches');
    if (response.data is List) {
      return (response.data as List).map((e) => DonorMatchModel.fromJson(e)).toList();
    }
    return [];
  }
}
