import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../core/services/audio_service.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _settingsFormKey = GlobalKey<FormState>();
  final _pinFormKey = GlobalKey<FormState>();

  late TextEditingController _phoneController;

  late TextEditingController _oldPinController;
  late TextEditingController _newPinController;
  late TextEditingController _confirmPinController;

  bool _isBookingEnabled = true;
  bool _isSavingSettings = false;
  bool _isChangingPin = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();

    _oldPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final loc = AppLocalization.of(context);
    if (!_settingsFormKey.currentState!.validate()) return;

    setState(() => _isSavingSettings = true);
    final settingsActions = ref.read(settingsActionsProvider);

    try {
      await settingsActions.updateSettings(
        restaurantPhone: _phoneController.text.trim(),
        isBookingEnabled: _isBookingEnabled,
      );

      if (mounted) {
        setState(() => _isSavingSettings = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('saved_successfully')),
            backgroundColor: AppColors.forestGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingSettings = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _changePin() async {
    final loc = AppLocalization.of(context);
    if (!_pinFormKey.currentState!.validate()) return;

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('pin_mismatch')),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    setState(() => _isChangingPin = true);

    final success = await ref.read(authProvider.notifier).changePin(
          _oldPinController.text.trim(),
          _newPinController.text.trim(),
        );

    if (mounted) {
      setState(() => _isChangingPin = false);
      if (success) {
        _oldPinController.clear();
        _newPinController.clear();
        _confirmPinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('pin_changed_success')),
            backgroundColor: AppColors.forestGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('invalid_old_pin')),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    final settingsAsync = ref.watch(adminSettingsStreamProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;
    final isMobile = screenWidth < 500;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('admin_settings'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkForest,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),

          settingsAsync.when(
            data: (settings) {
              if (_phoneController.text.isEmpty) {
                _phoneController.text = settings.restaurantPhone;
                _isBookingEnabled = settings.isBookingEnabled;
              }

              final generalCard = Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _settingsFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('restaurant_phone'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestGreen,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone_rounded),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 16),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            loc.translate('enable_bookings'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          value: _isBookingEnabled,
                          activeThumbColor: AppColors.forestGreen,
                          onChanged: (val) {
                            setState(() {
                              _isBookingEnabled = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: isMobile ? double.infinity : null,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isSavingSettings ? null : _saveSettings,
                            icon: const Icon(Icons.save_rounded),
                            label: _isSavingSettings
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(loc.translate('save_changes')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              final pinCard = Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _pinFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security_rounded,
                                color: AppColors.figGold),
                            const SizedBox(width: 8),
                            Text(
                              loc.translate('change_pin'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkForest,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _oldPinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            labelText: loc.translate('old_pin'),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (val) =>
                              val == null || val.length < 4 ? '4 أرقام' : null,
                        ),
                        const SizedBox(height: 10),

                        if (isMobile) ...[
                          TextFormField(
                            controller: _newPinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: loc.translate('new_pin'),
                              prefixIcon: const Icon(Icons.lock_clock),
                            ),
                            validator: (val) =>
                                val == null || val.length < 4
                                    ? '4 أرقام'
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: loc.translate('confirm_new_pin'),
                              prefixIcon: const Icon(Icons.lock_clock),
                            ),
                            validator: (val) =>
                                val == null || val.length < 4
                                    ? '4 أرقام'
                                    : null,
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _newPinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                    labelText: loc.translate('new_pin'),
                                    prefixIcon: const Icon(Icons.lock_clock),
                                  ),
                                  validator: (val) =>
                                      val == null || val.length < 4
                                          ? '4 أرقام'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _confirmPinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                    labelText: loc.translate('confirm_new_pin'),
                                    prefixIcon: const Icon(Icons.lock_clock),
                                  ),
                                  validator: (val) =>
                                      val == null || val.length < 4
                                          ? '4 أرقام'
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),

                        SizedBox(
                          width: isMobile ? double.infinity : null,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkForest,
                            ),
                            onPressed: _isChangingPin ? null : _changePin,
                            icon: const Icon(
                                Icons.published_with_changes_rounded),
                            label: _isChangingPin
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(loc.translate('change_pin')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              final notificationsCard = Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.notifications_active_rounded,
                              color: AppColors.figGold),
                          SizedBox(width: 8),
                          Text(
                            'إعدادات التنبيهات والأصوات 🔔',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkForest,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'عند وصول أي حجز جديد يتم تشغيل نغمة صوتية وإظهار راية تنبيه في المتصفح والنظام.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.forestGreen,
                            ),
                            onPressed: () async {
                              try {
                                await FirebaseMessaging.instance.requestPermission();
                              } catch (_) {}
                              await AudioService.playNewBookingNotification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تفعيل واختبار صوت التنبيه الفوري بنجاح 🔔',
                                        style: TextStyle(fontFamily: 'Cairo')),
                                    backgroundColor: AppColors.forestGreen,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.volume_up_rounded, size: 18),
                            label: const Text('اختبار وتفعيل صوت التنبيه 🔔',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );

              if (isDesktop) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: generalCard),
                        const SizedBox(width: 16),
                        Expanded(child: pinCard),
                      ],
                    ),
                    const SizedBox(height: 20),
                    notificationsCard,
                  ],
                );
              }

              return Column(
                children: [
                  generalCard,
                  const SizedBox(height: 20),
                  pinCard,
                  const SizedBox(height: 20),
                  notificationsCard,
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(loc.translate('error')),
          ),
        ],
      ),
    );
  }
}
