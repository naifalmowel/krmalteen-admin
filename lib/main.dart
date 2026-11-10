import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localization.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'views/auth/pin_login_screen.dart';
import 'views/dashboard/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC-lV554nWFlrR4pPwvNETyvc7FehxhMBA",
          authDomain: "krmalteenz.firebaseapp.com",
          projectId: "krmalteenz",
          storageBucket: "krmalteenz.firebasestorage.app",
          messagingSenderId: "87696190597",
          appId: "1:87696190597:web:3525c83fb8237c56af4dec",
          measurementId: "G-8G2CT3MD1D"
      ),
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize Supabase Storage
  try {
    await SupabaseService.initialize(
      url: AppConstants.defaultSupabaseUrl,
      anonKey: AppConstants.defaultSupabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  // Initialize Local Notifications
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(const ProviderScope(child: KrmAlteenAdminApp()));
}

class KrmAlteenAdminApp extends ConsumerWidget {
  const KrmAlteenAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Krm Alteen Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: currentLocale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: authState.isLoading
          ? const Scaffold(
              backgroundColor: AppColors.forestGreen,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.figGold),
              ),
            )
          : (authState.isAuthenticated
                ? const MainLayout()
                : const PinLoginScreen()),
    );
  }
}
