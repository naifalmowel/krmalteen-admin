import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/audio_service.dart';

final notificationGrantedProvider = StateProvider<bool>((ref) => false);

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  final VoidCallback onGranted;

  const NotificationPermissionScreen({super.key, required this.onGranted});

  @override
  ConsumerState<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestNotificationPermission() async {
    setState(() => _isRequesting = true);

    try {
      // 1. Request FCM / Browser Notifications Permissions
      try {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (_) {}

      // 2. Play test audio chime to prime Web Audio API
      await AudioService.playNewBookingNotification();

      // 3. Save state to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_granted_notifications', true);

      ref.read(notificationGrantedProvider.notifier).state = true;

      if (mounted) {
        widget.onGranted();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRequesting = false);
        widget.onGranted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkForest,
              AppColors.forestGreen,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: EdgeInsets.all(screenWidth < 400 ? 24.0 : 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  ClipOval(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.darkForest,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.figGold, width: 2),
                      ),
                      child: Image.asset(
                        'assets/logo.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.figGold,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'تفعيل إشعارات الحجوزات 🔔',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkForest,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'لضمان استقبال التنبيهات والأصوات الفورية عند وصول حجوزات جديدة، يرجى الموافقة على منح صلاحية الإشعارات للمتصفح.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isRequesting ? null : _requestNotificationPermission,
                      icon: _isRequesting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.notifications_active_rounded),
                      label: Text(
                        _isRequesting ? 'جاري التفعيل...' : 'موافق - تفعيل الإشعارات والصوت',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
