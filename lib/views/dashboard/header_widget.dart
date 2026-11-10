import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import 'main_layout.dart';

class HeaderWidget extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const HeaderWidget({super.key, this.onMenuPressed});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalization.of(context);
    final isArabic = loc.isArabic;
    final navIndex = ref.watch(navigationIndexProvider);
    final currentDate = DateFormat('EEEE, d MMMM yyyy', isArabic ? 'ar' : 'en')
        .format(DateTime.now());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    String getPageTitle(int index) {
      switch (index) {
        case 0:
          return loc.translate('nav_overview');
        case 1:
          return loc.translate('nav_menu');
        case 2:
          return loc.translate('nav_bookings');
        case 3:
          return loc.translate('nav_settings');
        default:
          return loc.translate('nav_overview');
      }
    }

    final headerTitle = isMobile ? loc.translate('restaurant_name') : getPageTitle(navIndex);

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
      decoration: const BoxDecoration(
        color: AppColors.darkForest,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (onMenuPressed != null) ...[
              IconButton(
                icon: const Icon(Icons.menu, color: AppColors.figGold),
                onPressed: onMenuPressed,
              ),
              const SizedBox(width: 4),
            ],

            // Round Logo Next to Name/Title
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                color: AppColors.figGold,
                child: Image.asset(
                  'assets/logo.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.restaurant,
                    color: AppColors.darkForest,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Title & Date
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    currentDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppColors.warmGold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Language Switcher Toggle
            InkWell(
              onTap: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 5 : 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.figGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, color: AppColors.figGold, size: isMobile ? 15 : 18),
                    const SizedBox(width: 4),
                    Text(
                      isArabic ? 'English' : 'عربي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Logout Button
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: loc.translate('logout'),
              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
