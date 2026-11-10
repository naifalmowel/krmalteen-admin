import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final List<String> _pinDigits = [];
  bool _isVerifying = false;
  String? _errorMessage;

  void _onKeyPress(String digit) {
    if (_pinDigits.length < 4) {
      setState(() {
        _errorMessage = null;
        _pinDigits.add(digit);
      });
      if (_pinDigits.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pinDigits.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _pinDigits.removeLast();
      });
    }
  }

  Future<void> _submitPin() async {
    final loc = AppLocalization.of(context);
    final pin = _pinDigits.join();
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).verifyPin(pin);

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
      if (!success) {
        setState(() {
          _pinDigits.clear();
          _errorMessage = loc.translate('invalid_pin');
        });
        // Auto hide error toast after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    final authState = ref.watch(authProvider);
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
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: EdgeInsets.all(screenWidth < 400 ? 20.0 : 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo & Restaurant Icon Header
                  ClipOval(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.darkForest,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.figGold, width: 2),
                      ),
                      child: Image.asset(
                        'assets/logo.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.restaurant,
                          color: AppColors.figGold,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.translate('restaurant_name'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.translate('login_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PIN Display Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _pinDigits.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? AppColors.figGold : Colors.transparent,
                          border: Border.all(
                            color: isFilled ? AppColors.figGold : AppColors.cardBorder,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Inline Error Toast Banner
                  if (_errorMessage != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red[700], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (_isVerifying || authState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: AppColors.figGold),
                    )
                  else ...[
                    // Numeric Keypad
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          // Language Switcher Button in Keypad
                          return InkWell(
                            onTap: () {
                              ref.read(localeProvider.notifier).toggleLocale();
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.softCream,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                loc.isArabic ? 'EN' : 'عربي',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forestGreen,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          );
                        } else if (index == 10) {
                          return _buildKeypadButton('0');
                        } else if (index == 11) {
                          // Backspace Button
                          return InkWell(
                            onTap: _onBackspace,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.softCream,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.backspace_outlined,
                                color: AppColors.forestGreen,
                                size: 20,
                              ),
                            ),
                          );
                        } else {
                          return _buildKeypadButton('${index + 1}');
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.softCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkForest,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
