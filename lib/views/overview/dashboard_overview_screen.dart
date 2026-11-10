import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/categories_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/bookings_provider.dart';

class DashboardOverviewScreen extends ConsumerWidget {
  final Function(int) onNavigate;

  const DashboardOverviewScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalization.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final menuItemsAsync = ref.watch(menuItemsStreamProvider);
    final bookingsAsync = ref.watch(bookingsStreamProvider);

    final totalCategories = categoriesAsync.asData?.value.length ?? 0;
    final totalMenuItems = menuItemsAsync.asData?.value.length ?? 0;
    final totalBookings = bookingsAsync.asData?.value.length ?? 0;
    final pendingBookings = bookingsAsync.asData?.value
            .where((b) => b.status == 'pending')
            .length ??
        0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Notification Notice Banner (Hidden automatically if notifications are already enabled)
          FutureBuilder<NotificationSettings>(
            future: FirebaseMessaging.instance.getNotificationSettings(),
            builder: (context, snapshot) {
              final isAuthorized = snapshot.hasData &&
                  snapshot.data?.authorizationStatus == AuthorizationStatus.authorized;

              if (isAuthorized) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.figGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.figGold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppColors.darkForest, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'لتجربة أفضل واستقبال أصوات تنبيه الحجوزات الفورية، يرجى تفعيل الإشعارات من صفحة الإعدادات.',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkForest,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate(3), // Navigate to Settings Screen exclusively
                          child: const Text(
                            '⚙️',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          Text(
            loc.translate('nav_overview'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkForest,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),

          // Stat Cards Grid - Full Width
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isDesktop = width > 800;
              final crossAxisCount = isDesktop ? 4 : 1;
              final childAspectRatio = isDesktop
                  ? 1.95
                  : (width < 400 ? 3.5 :3.8);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildStatCard(
                    title: loc.translate('total_categories'),
                    value: '$totalCategories',
                    icon: Icons.category_rounded,
                    color: AppColors.forestGreen,
                  ),
                  _buildStatCard(
                    title: loc.translate('total_menu_items'),
                    value: '$totalMenuItems',
                    icon: Icons.restaurant_menu_rounded,
                    color: AppColors.figGold,
                  ),
                  _buildStatCard(
                    title: loc.translate('total_bookings'),
                    value: '$totalBookings',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.statusCompleted,
                  ),
                  _buildStatCard(
                    title: loc.translate('pending_bookings'),
                    value: '$pendingBookings',
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.statusPending,
                    isHighlighted: pendingBookings > 0,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Quick Actions Section
          Text(
            loc.translate('quick_actions'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkForest,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),

          // Mobile-Responsive Action Buttons - Full Width
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final btnMenu = ElevatedButton.icon(
                onPressed: () => onNavigate(1), // Go to Menu & Categories
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  loc.translate('nav_menu'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );

              final btnBookings = ElevatedButton.icon(
                onPressed: () => onNavigate(2), // Go to Bookings
                icon: const Icon(Icons.notifications_active_rounded),
                label: Text(
                  '${loc.translate("nav_bookings")} ($pendingBookings)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figGold,
                  foregroundColor: AppColors.darkForest,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnMenu,
                    const SizedBox(height: 10),
                    btnBookings,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: btnMenu),
                  const SizedBox(width: 14),
                  Expanded(child: btnBookings),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Recent Bookings Summary - Full Width
          Text(
            loc.translate('recent_bookings'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkForest,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),

          bookingsAsync.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Center(
                      child: Text(
                        loc.translate('no_bookings'),
                        style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                );
              }
              final recentList = bookings.take(5).toList();

              return Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final booking = recentList[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(booking.status)
                            .withValues(alpha: 0.15),
                        child: Icon(
                          _getStatusIcon(booking.status),
                          color: _getStatusColor(booking.status),
                        ),
                      ),
                      title: Text(
                        booking.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                      subtitle: Text(
                        '${booking.guestsCount} أشخاص • ${booking.bookingDate}',
                        style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getStatusText(loc, booking.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'تنبيه: يرجى تفعيل صلاحيات القراءة والحفظ في Firebase Firestore Rules (Permission Denied)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red[700], fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? color : AppColors.cardBorder,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkForest,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'completed':
        return AppColors.statusCompleted;
      default:
        return AppColors.statusPending;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  String _getStatusText(AppLocalization loc, String status) {
    switch (status) {
      case 'confirmed':
        return loc.translate('status_confirmed');
      case 'cancelled':
        return loc.translate('status_cancelled');
      case 'completed':
        return loc.translate('status_completed');
      default:
        return loc.translate('status_pending');
    }
  }
}
