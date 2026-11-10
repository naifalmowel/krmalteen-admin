import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/booking_model.dart';
import '../../models/admin_settings_model.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= CATEGORIES =================
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        .orderBy('sortOrder', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .add(category.toFirestore());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(category.id)
        .update({
      'nameAr': category.nameAr,
      'nameEn': category.nameEn,
      'sortOrder': category.sortOrder,
    });
  }

  /// Batch update categories sortOrder using Firestore WriteBatch (Drag and Drop)
  Future<void> reorderCategories(List<CategoryModel> categories) async {
    final batch = _firestore.batch();
    for (int i = 0; i < categories.length; i++) {
      final ref = _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categories[i].id);
      batch.update(ref, {'sortOrder': i});
    }
    await batch.commit();
  }

  /// Checks how many menu items belong to a category before deletion
  Future<int> getMenuItemsCountForCategory(String categoryId) async {
    final query = await _firestore
        .collection(AppConstants.menuItemsCollection)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return query.docs.length;
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(categoryId)
        .delete();
  }

  // ================= MENU ITEMS =================
  Stream<List<MenuItemModel>> getMenuItemsStream({String? categoryId}) {
    return _firestore
        .collection(AppConstants.menuItemsCollection)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();

      if (categoryId != null && categoryId.isNotEmpty) {
        items.removeWhere((item) => item.categoryId != categoryId);
      }

      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    });
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .add(item.toFirestore());
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(item.id)
        .update(item.toFirestore());
  }

  /// Batch update menu items sortOrder using Firestore WriteBatch (Drag and Drop)
  Future<void> reorderMenuItems(List<MenuItemModel> items) async {
    final batch = _firestore.batch();
    for (int i = 0; i < items.length; i++) {
      final ref = _firestore
          .collection(AppConstants.menuItemsCollection)
          .doc(items[i].id);
      batch.update(ref, {'sortOrder': i});
    }
    await batch.commit();
  }

  /// Quick toggle availability status (Rule 2: Instant switch toggle)
  Future<void> toggleMenuItemAvailability(String itemId, bool isAvailable) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(itemId)
        .update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(itemId)
        .delete();
  }

  // ================= BOOKINGS =================
  Stream<List<BookingModel>> getBookingsStream() {
    return _firestore
        .collection(AppConstants.bookingsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({
      'status': newStatus,
    });
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(booking.id)
        .update(booking.toFirestore());
  }

  Future<void> addBooking(BookingModel booking) async {
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .add(booking.toFirestore());
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .delete();
  }

  // ================= ADMIN SETTINGS =================
  Stream<AdminSettingsModel> getAdminSettingsStream() {
    return _firestore
        .collection(AppConstants.adminSettingsCollection)
        .doc(AppConstants.adminConfigDocument)
        .snapshots()
        .map((doc) => AdminSettingsModel.fromFirestore(doc));
  }

  Future<AdminSettingsModel> getAdminSettingsOnce() async {
    final doc = await _firestore
        .collection(AppConstants.adminSettingsCollection)
        .doc(AppConstants.adminConfigDocument)
        .get();
    return AdminSettingsModel.fromFirestore(doc);
  }

  Future<void> updateAdminSettings(AdminSettingsModel settings) async {
    await _firestore
        .collection(AppConstants.adminSettingsCollection)
        .doc(AppConstants.adminConfigDocument)
        .set(settings.toFirestore(), SetOptions(merge: true));
  }
}
