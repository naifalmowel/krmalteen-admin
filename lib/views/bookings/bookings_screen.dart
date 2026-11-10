import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../core/utils/helpers.dart';
import '../../models/booking_model.dart';
import '../../providers/bookings_provider.dart';
import 'booking_dialog.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  void _showBookingDialog(BuildContext context, [BookingModel? booking]) {
    showDialog(
      context: context,
      builder: (_) => BookingDialog(bookingToEdit: booking),
    );
  }

  Future<void> _openWhatsApp({
    required BuildContext context,
    required BookingModel booking,
    required String targetStatus,
    required bool isArabic,
  }) async {
    final cleanPhone = AppHelpers.getWhatsAppCleanPhone(booking.phone);
    final message = AppHelpers.generateWhatsAppBookingMessage(
      fullName: booking.fullName,
      guestsCount: booking.guestsCount,
      bookingDate: booking.bookingDate,
      bookingTime: booking.bookingTime,
      status: targetStatus,
      isArabic: isArabic,
    );

    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMsg');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = AppHelpers.formatPhoneNumber(phone);
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalization.of(context);
    final isArabic = loc.isArabic;
    final bookingsAsync = ref.watch(filteredBookingsProvider);
    final bookingActions = ref.read(bookingActionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('nav_bookings'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkForest,
                  fontFamily: 'Cairo',
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBookingDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة حجز', style: TextStyle(fontSize: 13, fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(ref, loc, 'all', loc.translate('filter_all')),
                _buildFilterChip(
                    ref, loc, 'pending', loc.translate('filter_pending'),
                    color: AppColors.statusPending),
                _buildFilterChip(
                    ref, loc, 'confirmed', loc.translate('filter_confirmed'),
                    color: AppColors.statusConfirmed),
                _buildFilterChip(
                    ref, loc, 'cancelled', loc.translate('filter_cancelled'),
                    color: AppColors.statusCancelled),
                _buildFilterChip(
                    ref, loc, 'completed', loc.translate('filter_completed'),
                    color: AppColors.statusCompleted),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3-Tier Responsive Bookings Layout: 1 (Mobile) | 2 (Tablet/Medium) | 3 (Web/Desktop)
          bookingsAsync.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 50, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            loc.translate('no_bookings'),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount = 1;
                  double childAspectRatio = 1.0;

                  if (width >= 1100) {
                    crossAxisCount = 3; // 3 on Web / Large Screens
                    childAspectRatio = 1.55;
                  } else if (width >= 600) {
                    crossAxisCount = 2; // 2 on Medium / Tablet
                    childAspectRatio = 0.8;
                  } else {
                    crossAxisCount = 1; // 1 on Mobile
                  }

                  if (crossAxisCount > 1) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _buildBookingCard(
                            context, ref, loc, booking, bookingActions, isArabic);
                      },
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bookings.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _buildBookingCard(
                            context, ref, loc, booking, bookingActions, isArabic);
                      },
                    );
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(loc.translate('error')),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    AppLocalization loc,
    String key,
    String label, {
    Color? color,
  }) {
    final selectedFilter = ref.watch(bookingStatusFilterProvider);
    final isSelected = selectedFilter == key;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        selectedColor: color ?? AppColors.forestGreen,
        onSelected: (_) {
          ref.read(bookingStatusFilterProvider.notifier).state = key;
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalization loc,
    BookingModel booking,
    BookingActions actions,
    bool isArabic,
  ) {
    final statusColor = _getStatusColor(booking.status);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile) ...[
                  // Mobile Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.forestGreen.withValues(alpha: 0.1),
                              child: const Icon(Icons.person,
                                  color: AppColors.forestGreen, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkForest,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          _getStatusText(loc, booking.status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              AppHelpers.formatPhoneNumber(booking.phone),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'تعديل الحجز',
                            iconSize: 18,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            icon: const Icon(Icons.edit_outlined, color: AppColors.forestGreen),
                            onPressed: () => _showBookingDialog(context, booking),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: 'حذف الحجز',
                            iconSize: 18,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(loc.translate('delete_confirm_title')),
                                  content: Text(loc.translate('delete_confirm_msg')),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(loc.translate('cancel')),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text(loc.translate('delete')),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await actions.deleteBooking(booking.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  // Desktop / Tablet Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.forestGreen.withValues(alpha: 0.1),
                              child: const Icon(Icons.person,
                                  color: AppColors.forestGreen, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkForest,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      AppHelpers.formatPhoneNumber(booking.phone),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor, width: 1),
                              ),
                              child: Text(
                                _getStatusText(loc, booking.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'تعديل الحجز',
                            iconSize: 18,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            icon: const Icon(Icons.edit_outlined, color: AppColors.forestGreen),
                            onPressed: () => _showBookingDialog(context, booking),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: 'حذف الحجز',
                            iconSize: 18,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(loc.translate('delete_confirm_title')),
                                  content: Text(loc.translate('delete_confirm_msg')),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(loc.translate('cancel')),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text(loc.translate('delete')),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await actions.deleteBooking(booking.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Booking Details Grid / Wrap
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoBadge(
                      Icons.group_rounded,
                      '${loc.translate("guests_count")}: ${booking.guestsCount}',
                    ),
                    _buildInfoBadge(
                      Icons.calendar_today_rounded,
                      '${loc.translate("booking_date")}: ${booking.bookingDate}',
                    ),
                    _buildInfoBadge(
                      Icons.access_time_rounded,
                      '${loc.translate("booking_time")}: ${booking.bookingTime}',
                    ),
                    _buildInfoBadge(
                      Icons.chair_alt_rounded,
                      '${loc.translate("seating_preference")}: ${_getSeatingText(loc, booking.seatingPreference)}',
                    ),
                  ],
                ),

                if (booking.specialRequests.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.softCream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${loc.translate("special_requests")}: ${booking.specialRequests}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ],
            ),

            Column(
              children: [
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Actions Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 450;

                    final btnCall = OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(booking.phone),
                      icon: const Icon(Icons.call, size: 15),
                      label: Text(
                        loc.translate('call_now'),
                        style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forestGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    );

                    final btnWhatsApp = ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(
                        context: context,
                        booking: booking,
                        targetStatus:
                            booking.status == 'cancelled' ? 'cancelled' : 'confirmed',
                        isArabic: isArabic,
                      ),
                      icon: const Icon(Icons.chat, size: 15),
                      label: Text(
                        loc.translate('whatsapp_chat'),
                        style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    );

                    Widget? statusActions;
                    if (booking.status == 'pending') {
                      statusActions = Row(
                        mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
                        children: [
                          Expanded(
                            flex: isNarrow ? 1 : 0,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[700],
                                side: BorderSide(color: Colors.red[700]!),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              onPressed: () async {
                                await actions.updateStatus(booking.id, 'cancelled');
                                if (context.mounted) {
                                  _openWhatsApp(
                                    context: context,
                                    booking: booking,
                                    targetStatus: 'cancelled',
                                    isArabic: isArabic,
                                  );
                                }
                              },
                              child: Text(
                                loc.translate('cancel_booking'),
                                style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: isNarrow ? 1 : 0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusConfirmed,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              onPressed: () async {
                                await actions.updateStatus(booking.id, 'confirmed');
                                if (context.mounted) {
                                  _openWhatsApp(
                                    context: context,
                                    booking: booking,
                                    targetStatus: 'confirmed',
                                    isArabic: isArabic,
                                  );
                                }
                              },
                              child: Text(
                                loc.translate('confirm_booking'),
                                style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (booking.status == 'confirmed') {
                      statusActions = ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusCompleted,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        onPressed: () async {
                          await actions.updateStatus(booking.id, 'completed');
                        },
                        child: Text(
                          loc.translate('complete_booking'),
                          style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                        ),
                      );
                    }

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: btnCall),
                              const SizedBox(width: 6),
                              Expanded(child: btnWhatsApp),
                            ],
                          ),
                          if (statusActions != null) ...[
                            const SizedBox(height: 8),
                            statusActions,
                          ],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        btnCall,
                        const SizedBox(width: 8),
                        btnWhatsApp,
                        const Spacer(),
                        if (statusActions != null) ...[
                          statusActions,
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.figGold),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
      ],
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

  String _getSeatingText(AppLocalization loc, String pref) {
    switch (pref) {
      case 'summer_garden':
        return loc.translate('summer_garden');
      case 'winter_lounge':
        return loc.translate('winter_lounge');
      default:
        return loc.translate('seating_any');
    }
  }
}
