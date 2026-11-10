import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localization.dart';
import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';
import 'category_dialog.dart';

class CategoryManagerModal extends ConsumerWidget {
  const CategoryManagerModal({super.key});

  void _showCategoryDialog(BuildContext context, [CategoryModel? category]) {
    showDialog(
      context: context,
      builder: (_) => CategoryDialog(categoryToEdit: category),
    );
  }

  Future<void> _deleteCategoryWithRuleCheck(
      BuildContext context, WidgetRef ref, CategoryModel category) async {
    final loc = AppLocalization.of(context);
    final actions = ref.read(categoriesActionsProvider);

    final result = await actions.checkCanDeleteCategory(category.id);

    if (!context.mounted) return;

    if (!result.canDelete) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          title: Text(
            loc.translate('category_delete_error_title'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          content: Text(
            loc
                .translate('category_delete_error_msg')
                .replaceAll('{count}', result.itemsCount.toString()),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('confirm')),
            ),
          ],
        ),
      );
    } else {
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
        await actions.deleteCategory(category.id);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalization.of(context);
    final isArabic = loc.isArabic;
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      titlePadding: EdgeInsets.all(isMobile ? 12 : 20),
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            loc.translate('categories'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo'),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(loc.translate('add_category'),
                style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 480),
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return Center(
                  child: Text(
                    loc.translate('no_data'),
                    style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
                  ),
                );
              }

              return ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final list = List<CategoryModel>.from(categories);
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);

                  final actions = ref.read(categoriesActionsProvider);
                  await actions.reorderCategories(list);
                },
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    key: ValueKey(cat.id.isNotEmpty ? '${cat.id}_$index' : 'cat_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.softCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? cat.nameAr : cat.nameEn,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.darkForest,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                isArabic ? cat.nameEn : cat.nameAr,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          tooltip: loc.translate('edit_category'),
                          icon: const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.forestGreen),
                          onPressed: () => _showCategoryDialog(context, cat),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          tooltip: loc.translate('delete_category'),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red),
                          onPressed: () =>
                              _deleteCategoryWithRuleCheck(context, ref, cat),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(loc.translate('error')),
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
