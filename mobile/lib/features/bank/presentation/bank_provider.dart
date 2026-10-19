import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bank_models.dart';
import '../data/bank_repository.dart';

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepository();
});

final bankDashboardProvider = FutureProvider.autoDispose<BankDashboardModel>((ref) async {
  final repo = ref.watch(bankRepositoryProvider);
  return repo.getDashboard();
});

final donationCampsProvider = FutureProvider.autoDispose<List<DonationCampModel>>((ref) async {
  final repo = ref.watch(bankRepositoryProvider);
  return repo.getNearbyCamps();
});
