import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';

class SidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);

    return Container(
      width: 250,
      color: AppColors.forestGreen,
      child: Column(
        children: [
          // Header Branding Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            color: AppColors.darkForest,
            child: Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: AppColors.figGold,
                    child: Image.asset(
                      'assets/logo.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.darkForest,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('restaurant_name'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warmGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Navigation Items
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.dashboard_rounded,
            title: loc.translate('nav_overview'),
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.restaurant_rounded,
            title: loc.translate('nav_menu'),
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.book_online_rounded,
            title: loc.translate('nav_bookings'),
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.settings_rounded,
            title: loc.translate('nav_settings'),
          ),

          const Spacer(),

          // Bottom Footer Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0 • كرم التين',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => onItemSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.figGold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.darkForest : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.darkForest : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
