import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../overview/dashboard_overview_screen.dart';
import '../menu/menu_management_screen.dart';
import '../bookings/bookings_screen.dart';
import '../settings/settings_screen.dart';
import 'header_widget.dart';
import 'sidebar_widget.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    Widget getBodyView(int index) {
      switch (index) {
        case 0:
          return DashboardOverviewScreen(
            onNavigate: (i) {
              ref.read(navigationIndexProvider.notifier).state = i;
            },
          );
        case 1:
          return const MenuManagementScreen();
        case 2:
          return const BookingsScreen();
        case 3:
          return const SettingsScreen();
        default:
          return DashboardOverviewScreen(
            onNavigate: (i) {
              ref.read(navigationIndexProvider.notifier).state = i;
            },
          );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          // Desktop / Web Responsive Layout with Permanent Sidebar
          return Scaffold(
            body: Row(
              children: [
                SidebarWidget(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    ref.read(navigationIndexProvider.notifier).state = index;
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      const HeaderWidget(),
                      Expanded(
                        child: Container(
                          color: AppColors.softCream,
                          child: getBodyView(selectedIndex),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout with Compact Bottom Navigation Bar
          return Scaffold(
            appBar: const HeaderWidget(),
            body: Container(
              color: AppColors.softCream,
              child: getBodyView(selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              selectedItemColor: AppColors.forestGreen,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                ref.read(navigationIndexProvider.notifier).state = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'عامة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_rounded),
                  label: 'المنيو',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_online_rounded),
                  label: 'الحجوزات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'الإعدادات',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
