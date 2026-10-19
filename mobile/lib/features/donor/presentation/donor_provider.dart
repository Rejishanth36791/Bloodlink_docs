import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/donor_models.dart';
import '../data/donor_repository.dart';

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return DonorRepository();
});

final nearbyAppealsProvider = FutureProvider.autoDispose<List<AppealModel>>((ref) async {
  final repo = ref.watch(donorRepositoryProvider);
  return repo.getNearbyAppeals();
});

final donorAlertsProvider = FutureProvider.autoDispose<List<MatchAlertModel>>((ref) async {
  final repo = ref.watch(donorRepositoryProvider);
  return repo.getDonorAlerts();
});

class DonorAvailabilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  Future<void> toggle(bool newValue) async {
    state = newValue;
    try {
      final repo = ref.read(donorRepositoryProvider);
      await repo.toggleAvailability(newValue);
    } catch (_) {
      state = !newValue;
    }
  }
}

final donorAvailabilityProvider =
    NotifierProvider<DonorAvailabilityNotifier, bool>(DonorAvailabilityNotifier.new);
