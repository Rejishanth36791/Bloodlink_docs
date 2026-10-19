import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/request_models.dart';
import '../data/request_repository.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository();
});

final myRequestsProvider = FutureProvider.autoDispose<List<BloodRequestModel>>((ref) async {
  final repo = ref.watch(requestRepositoryProvider);
  return repo.getMyRequests();
});

final requestDetailProvider =
    FutureProvider.autoDispose.family<BloodRequestModel, String>((ref, id) async {
  final repo = ref.watch(requestRepositoryProvider);
  return repo.getRequestById(id);
});

final requestMatchesProvider =
    FutureProvider.autoDispose.family<List<DonorMatchModel>, String>((ref, requestId) async {
  final repo = ref.watch(requestRepositoryProvider);
  return repo.getMatches(requestId);
});
