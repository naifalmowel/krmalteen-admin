import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../core/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getCategoriesStream();
});

class CategoryDeletionResult {
  final bool canDelete;
  final int itemsCount;

  CategoryDeletionResult({required this.canDelete, required this.itemsCount});
}

final categoriesActionsProvider = Provider<CategoryActions>((ref) {
  return CategoryActions(ref.watch(firestoreServiceProvider));
});

class CategoryActions {
  final FirestoreService _firestoreService;

  CategoryActions(this._firestoreService);

  Future<void> addCategory(String nameAr, String nameEn, int sortOrder) async {
    final category = CategoryModel(
      id: '',
      nameAr: nameAr,
      nameEn: nameEn,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
    await _firestoreService.addCategory(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestoreService.updateCategory(category);
  }

  Future<void> reorderCategories(List<CategoryModel> categories) async {
    await _firestoreService.reorderCategories(categories);
  }

  /// Checks Business Rule #1 before deletion
  Future<CategoryDeletionResult> checkCanDeleteCategory(String categoryId) async {
    final count = await _firestoreService.getMenuItemsCountForCategory(categoryId);
    return CategoryDeletionResult(
      canDelete: count == 0,
      itemsCount: count,
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestoreService.deleteCategory(categoryId);
  }
}
