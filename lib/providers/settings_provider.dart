import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_settings_model.dart';
import '../core/services/firestore_service.dart';
import 'categories_provider.dart';

final adminSettingsStreamProvider = StreamProvider<AdminSettingsModel>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAdminSettingsStream();
});

final settingsActionsProvider = Provider<SettingsActions>((ref) {
  return SettingsActions(ref.watch(firestoreServiceProvider));
});

class SettingsActions {
  final FirestoreService _firestoreService;

  SettingsActions(this._firestoreService);

  Future<void> updateSettings({
    required String restaurantPhone,
    required bool isBookingEnabled,
  }) async {
    final current = await _firestoreService.getAdminSettingsOnce();
    final updated = current.copyWith(
      restaurantPhone: restaurantPhone,
      isBookingEnabled: isBookingEnabled,
    );
    await _firestoreService.updateAdminSettings(updated);
  }
}
