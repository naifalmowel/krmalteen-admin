import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../models/menu_item_model.dart';
import '../../providers/menu_provider.dart';

class ReorderMenuItemsModal extends ConsumerWidget {
  const ReorderMenuItemsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalization.of(context);
    final isArabic = loc.isArabic;
    final menuItemsAsync = ref.watch(filteredMenuItemsProvider);
    final menuActions = ref.read(menuActionsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 12 : 24,
      ),
      titlePadding: EdgeInsets.all(isMobile ? 12 : 20),
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: 8),
      title: Row(
        children: const [
          Icon(Icons.reorder_rounded, color: AppColors.forestGreen),
          SizedBox(width: 8),
          Text(
            'إعادة ترتيب الوجبات بالسحب',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo'),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 500),
          child: menuItemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    loc.translate('no_data'),
                    style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
                  ),
                );
              }

              return ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final list = List<MenuItemModel>.from(items);
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);

                  await menuActions.reorderMenuItems(list);
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    key: ValueKey(item.id.isNotEmpty ? '${item.id}_$index' : 'item_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.darkForest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warmGold,
                              fontSize: 11,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 40,
                            height: 40,
                            color: Colors.white,
                            child: item.imageUrl.isNotEmpty
                                ? Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 18, color: AppColors.textMuted),
                                  )
                                : const Icon(Icons.fastfood, size: 18, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? item.nameAr : item.nameEn,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.darkForest,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                isArabic ? item.descriptionAr : item.descriptionEn,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(loc.translate('error')),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.translate('confirm')),
        ),
      ],
    );
  }
}
