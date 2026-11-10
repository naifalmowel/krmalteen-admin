import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../core/utils/helpers.dart';
import '../../models/category_model.dart';
import '../../models/menu_item_model.dart';
import '../../providers/categories_provider.dart';
import '../../providers/menu_provider.dart';
import 'category_manager_modal.dart';
import 'menu_item_dialog.dart';
import 'reorder_menu_items_modal.dart';

final menuViewModeProvider = StateProvider<String>((ref) => 'grid'); // 'grid' or 'list'

class MenuManagementScreen extends ConsumerWidget {
  const MenuManagementScreen({super.key});

  void _showCategoryManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CategoryManagerModal(),
    );
  }

  void _showReorderMenuItemsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ReorderMenuItemsModal(),
    );
  }

  void _showMenuItemDialog(
    BuildContext context,
    List<CategoryModel> categories, [
    MenuItemModel? item,
    String? currentCatId,
  ]) {
    showDialog(
      context: context,
      builder: (_) => MenuItemDialog(
        itemToEdit: item,
        categories: categories,
        initialCategoryId: currentCatId,
      ),
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.darkForest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 520),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Icon(Icons.broken_image, size: 60, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalization.of(context);
    final isArabic = loc.isArabic;
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final menuItemsAsync = ref.watch(filteredMenuItemsProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final viewMode = ref.watch(menuViewModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Screen Header Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final titleText = Text(
                loc.translate('nav_menu'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkForest,
                  fontFamily: 'Cairo',
                ),
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showCategoryManager(context),
                    icon: const Icon(Icons.category_outlined, size: 17),
                    label: Text(
                      loc.translate('categories'),
                      style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showReorderMenuItemsModal(context),
                    icon: const Icon(Icons.reorder_rounded, size: 17),
                    label: const Text(
                      'ترتيب الوجبات',
                      style: TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      categoriesAsync.whenData((cats) {
                        if (cats.isNotEmpty) {
                          _showMenuItemDialog(context, cats, null, selectedCatId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate('add_category'))),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: Text(
                      loc.translate('add_item'),
                      style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText,
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: actionButtons,
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleText,
                  actionButtons,
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Categories Horizontal Filter / Selector
          categoriesAsync.when(
            data: (categories) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All Categories" Chip
                        FilterChip(
                          selected: selectedCatId == null,
                          label: Text(
                            loc.translate('all_categories'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selectedCatId == null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selectedCatId == null
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          selectedColor: AppColors.forestGreen,
                          onSelected: (_) {
                            ref.read(selectedCategoryIdProvider.notifier).state = null;
                          },
                        ),
                        const SizedBox(width: 8),

                        ...categories.map((cat) {
                          final isSelected = selectedCatId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(
                                isArabic ? cat.nameAr : cat.nameEn,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              selectedColor: AppColors.forestGreen,
                              onSelected: (_) {
                                ref.read(selectedCategoryIdProvider.notifier).state =
                                    cat.id;
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Side-by-side Search Bar & View Mode Toggle (Half-width on Web, Full-width on Mobile)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 800;

                      final searchField = TextField(
                        onChanged: (val) {
                          ref.read(searchQueryProvider.notifier).state = val;
                        },
                        decoration: InputDecoration(
                          hintText: loc.translate('search_placeholder'),
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    ref.read(searchQueryProvider.notifier).state = '';
                                  },
                                )
                              : null,
                        ),
                      );

                      final toggleButtons = Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'عرض شبكة (Grid)',
                              iconSize: 18,
                              icon: Icon(
                                Icons.grid_view_rounded,
                                color: viewMode == 'grid'
                                    ? AppColors.forestGreen
                                    : AppColors.textMuted,
                              ),
                              onPressed: () => ref
                                  .read(menuViewModeProvider.notifier)
                                  .state = 'grid',
                            ),
                            Container(
                                width: 1, height: 24, color: AppColors.cardBorder),
                            IconButton(
                              tooltip: 'عرض قائمة (List)',
                              iconSize: 18,
                              icon: Icon(
                                Icons.view_list_rounded,
                                color: viewMode == 'list'
                                    ? AppColors.forestGreen
                                    : AppColors.textMuted,
                              ),
                              onPressed: () => ref
                                  .read(menuViewModeProvider.notifier)
                                  .state = 'list',
                            ),
                          ],
                        ),
                      );

                      if (isDesktop) {
                        return Row(
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 0.5,
                              child: searchField,
                            ),
                            const SizedBox(width: 16),
                            toggleButtons,
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: searchField),
                            const SizedBox(width: 8),
                            toggleButtons,
                          ],
                        );
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const SizedBox(),
          ),

          const SizedBox(height: 20),

          // Menu Items View (Grid or List Mode)
          menuItemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant_menu_outlined,
                              size: 50, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            loc.translate('no_data'),
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

              return categoriesAsync.when(
                data: (categories) {
                  if (viewMode == 'grid') {
                    // Grid View
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final isDesktop = width > 900;
                        final isTablet = width > 600;
                        final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                        final childAspectRatio = 1.7;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _buildMenuItemCard(
                                context, ref, loc, item, categories);
                          },
                        );
                      },
                    );
                  } else {
                    // List View (Compact Horizontal Row Card)
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildHorizontalListItemCard(
                            context, ref, loc, item, categories);
                      },
                    );
                  }
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const SizedBox(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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

  // ================= GRID CARD =================
  Widget _buildMenuItemCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalization loc,
    MenuItemModel item,
    List<CategoryModel> categories,
  ) {
    final isArabic = loc.isArabic;
    final menuActions = ref.read(menuActionsProvider);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Banner & Badges (Compact Height)
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showImagePreviewDialog(
                    context,
                    item.imageUrl,
                    isArabic ? item.nameAr : item.nameEn,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.softCream,
                      image: item.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.imageUrl.isEmpty
                        ? const Icon(Icons.fastfood_rounded,
                            size: 36, color: AppColors.textMuted)
                        : null,
                  ),
                ),

                // Zoom Icon Overlay
                if (item.imageUrl.isNotEmpty)
                  Positioned(
                    bottom: 6,
                    left: isArabic ? 6 : null,
                    right: isArabic ? null : 6,
                    child: InkWell(
                      onTap: () => _showImagePreviewDialog(
                        context,
                        item.imageUrl,
                        isArabic ? item.nameAr : item.nameEn,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),

                // Quick Actions Overlay (Edit / Delete)
                Positioned(
                  top: 6,
                  right: isArabic ? null : 6,
                  left: isArabic ? 6 : null,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 14,
                        child: IconButton(
                          iconSize: 14,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit_rounded,
                              color: AppColors.forestGreen),
                          onPressed: () => _showMenuItemDialog(
                              context, categories, item, item.categoryId),
                        ),
                      ),
                      const SizedBox(width: 4),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 14,
                        child: IconButton(
                          iconSize: 14,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_rounded, color: Colors.red),
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
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700]),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(loc.translate('delete')),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await menuActions.deleteMenuItem(item.id);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Price Badge
                Positioned(
                  bottom: 6,
                  right: isArabic ? 6 : null,
                  left: isArabic ? null : 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.darkForest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppHelpers.formatCurrencySYP(item.price, isArabic: isArabic),
                      style: const TextStyle(
                        color: AppColors.warmGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Body (Compact Padding)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? item.nameAr : item.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkForest,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isArabic ? item.descriptionAr : item.descriptionEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),

                  // Tags & Availability Switch Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.tags.isNotEmpty)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.figGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.tags.first,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Availability Switch
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.isAvailable
                                ? loc.translate('available')
                                : loc.translate('unavailable'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.isAvailable
                                  ? AppColors.forestGreen
                                  : Colors.red[700],
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            height: 22,
                            child: Switch(
                              value: item.isAvailable,
                              activeThumbColor: AppColors.forestGreen,
                              onChanged: (val) {
                                menuActions.toggleAvailability(
                                    item.id, item.isAvailable);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HORIZONTAL LIST ITEM CARD =================
  Widget _buildHorizontalListItemCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalization loc,
    MenuItemModel item,
    List<CategoryModel> categories,
  ) {
    final isArabic = loc.isArabic;
    final menuActions = ref.read(menuActionsProvider);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Image Thumbnail with Zoom
            GestureDetector(
              onTap: () => _showImagePreviewDialog(
                context,
                item.imageUrl,
                isArabic ? item.nameAr : item.nameEn,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70,
                  height: 70,
                  color: AppColors.softCream,
                  child: item.imageUrl.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(item.imageUrl, fit: BoxFit.cover),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.zoom_in_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        )
                      : const Icon(Icons.fastfood_rounded,
                          color: AppColors.textMuted, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isArabic ? item.nameAr : item.nameEn,
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.darkForest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppHelpers.formatCurrencySYP(item.price,
                              isArabic: isArabic),
                          style: const TextStyle(
                            color: AppColors.warmGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isArabic ? item.descriptionAr : item.descriptionEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (item.tags.isNotEmpty)
                        ...item.tags.take(2).map((tag) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.figGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forestGreen,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            )),
                      const Spacer(),
                      // Availability Switch
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.isAvailable
                                ? loc.translate('available')
                                : loc.translate('unavailable'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.isAvailable
                                  ? AppColors.forestGreen
                                  : Colors.red[700],
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            height: 24,
                            child: Switch(
                              value: item.isAvailable,
                              activeThumbColor: AppColors.forestGreen,
                              onChanged: (val) {
                                menuActions.toggleAvailability(
                                    item.id, item.isAvailable);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Edit & Delete Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: loc.translate('edit_item'),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.forestGreen),
                  onPressed: () => _showMenuItemDialog(
                      context, categories, item, item.categoryId),
                ),
                const SizedBox(height: 16),
                IconButton(
                  tooltip: loc.translate('delete_item'),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700]),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(loc.translate('delete')),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await menuActions.deleteMenuItem(item.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
