import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';
import '../core/services/firestore_service.dart';
import 'categories_provider.dart';

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final menuItemsStreamProvider = StreamProvider<List<MenuItemModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);
  return firestoreService.getMenuItemsStream(categoryId: categoryId);
});

final filteredMenuItemsProvider = Provider<AsyncValue<List<MenuItemModel>>>((ref) {
  final menuAsync = ref.watch(menuItemsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

  return menuAsync.whenData((items) {
    if (searchQuery.isEmpty) return items;
    return items.where((item) {
      final matchAr = item.nameAr.toLowerCase().contains(searchQuery);
      final matchEn = item.nameEn.toLowerCase().contains(searchQuery);
      final matchTags = item.tags.any((t) => t.toLowerCase().contains(searchQuery));
      return matchAr || matchEn || matchTags;
    }).toList();
  });
});

final menuActionsProvider = Provider<MenuActions>((ref) {
  return MenuActions(ref.watch(firestoreServiceProvider));
});

class MenuActions {
  final FirestoreService _firestoreService;

  MenuActions(this._firestoreService);

  Future<void> addMenuItem(MenuItemModel item) async {
    await _firestoreService.addMenuItem(item);
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await _firestoreService.updateMenuItem(item);
  }

  Future<void> reorderMenuItems(List<MenuItemModel> items) async {
    await _firestoreService.reorderMenuItems(items);
  }

  /// Quick toggle availability status (Rule 2)
  Future<void> toggleAvailability(String itemId, bool currentStatus) async {
    await _firestoreService.toggleMenuItemAvailability(itemId, !currentStatus);
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _firestoreService.deleteMenuItem(itemId);
  }
}
