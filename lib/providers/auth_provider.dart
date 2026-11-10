import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firestore_service.dart';
import '../core/utils/helpers.dart';
import '../core/constants/app_constants.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isAuthenticated: false, isLoading: true)) {
    _checkStoredSession();
  }

  static const String _authSessionKey = 'is_admin_authenticated';
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _checkStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool(_authSessionKey) ?? false;
      state = AuthState(isAuthenticated: isAuthenticated, isLoading: false);
    } catch (_) {
      state = AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final settings = await _firestoreService.getAdminSettingsOnce();
      final enteredHash = AppHelpers.hashPin(enteredPin);

      if (enteredHash == settings.pinHash) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authSessionKey, true);
        state = AuthState(isAuthenticated: true, isLoading: false);
        return true;
      } else {
        state = AuthState(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: 'invalid_pin',
        );
        return false;
      }
    } catch (e) {
      // Fallback check against default PIN if network/firestore error
      final enteredHash = AppHelpers.hashPin(enteredPin);
      final defaultHash = AppHelpers.hashPin(AppConstants.defaultPin);
      if (enteredHash == defaultHash) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authSessionKey, true);
        state = AuthState(isAuthenticated: true, isLoading: false);
        return true;
      }
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'invalid_pin',
      );
      return false;
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final settings = await _firestoreService.getAdminSettingsOnce();
      final oldHash = AppHelpers.hashPin(oldPin);

      if (oldHash != settings.pinHash) {
        return false;
      }

      final newHash = AppHelpers.hashPin(newPin);
      final updatedSettings = settings.copyWith(pinHash: newHash);
      await _firestoreService.updateAdminSettings(updatedSettings);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authSessionKey, false);
    state = AuthState(isAuthenticated: false, isLoading: false);
  }
}
