import 'package:flutter/material.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization) ??
        AppLocalization(const Locale('ar'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_title': 'كرم التين - لوحة التحكم الإدارية',
      'restaurant_name': 'كرم التين',
      'login_title': 'تسجيل الدخول للوحة التحكم',
      'enter_pin': 'أدخل رمز الـ PIN المكون من 4 أرقام',
      'invalid_pin': 'رمز PIN غير صحيح، يرجى المحاولة مرة أخرى',
      'logout': 'تسجيل الخروج',

      // Navigation
      'nav_overview': 'نظرة عامة',
      'nav_menu': 'إدارة المنيو والأقسام',
      'nav_bookings': 'إدارة الحجوزات',
      'nav_settings': 'الإعدادات والأمان',

      // Overview
      'total_categories': 'إجمالي الأقسام',
      'total_menu_items': 'إجمالي الوجبات',
      'total_bookings': 'إجمالي الحجوزات',
      'pending_bookings': 'حجوزات جديدة بانتظار التأكيد',
      'recent_bookings': 'أحدث الحجوزات',
      'quick_actions': 'إجراءات سريعة',

      // Menu & Categories
      'categories': 'الأقسام',
      'menu_items': 'الوجبات والمأكولات',
      'add_category': 'إضافة قسم جديد',
      'edit_category': 'تعديل القسم',
      'delete_category': 'حذف القسم',
      'category_name_ar': 'اسم القسم (بالعربية)',
      'category_name_en': 'اسم القسم (بالإنجليزية)',
      'sort_order': 'ترتيب العرض',
      'add_item': 'إضافة وجبة جديدة',
      'edit_item': 'تعديل الوجبة',
      'delete_item': 'حذف الوجبة',
      'item_name_ar': 'اسم الوجبة (بالعربية)',
      'item_name_en': 'اسم الوجبة (بالإنجليزية)',
      'desc_ar': 'الوصف (بالعربية)',
      'desc_en': 'الوصف (بالإنجليزية)',
      'price_syp': 'السعر (ليرة سورية SYP)',
      'select_category': 'اختر القسم',
      'tags_comma': 'الأوسمة (مفصولة بفاصلة مثل: طازج, الأكثر طلباً)',
      'available': 'متوفر',
      'unavailable': 'غير متوفر حالياً',
      'upload_image': 'رفع صورة من الجهاز',
      'change_image': 'تغيير الصورة',
      'image_required': 'يرجى اختيار صورة للوجبة',
      'search_placeholder': 'ابحث باسم الوجبة بالعربي أو الإنجليزي...',
      'all_categories': 'جميع الأقسام',
      'category_delete_error_title': 'تعذر حذف القسم',
      'category_delete_error_msg': 'لا يمكن حذف هذا القسم لأنه يحتوي على {count} منتجات. يرجى نقل أو حذف المنتجات أولاً.',

      // Bookings
      'booking_id': 'رقم الحجز',
      'customer_name': 'اسم الزبون',
      'phone_number': 'رقم الهاتف',
      'guests_count': 'عدد الأشخاص',
      'booking_date': 'تاريخ الحجز',
      'booking_time': 'وقت الحجز',
      'seating_preference': 'تفضيل الجلسة',
      'special_requests': 'ملاحظات إضافية',
      'status': 'حالة الحجز',
      'status_pending': 'جديد (بانتظار التأكيد)',
      'status_confirmed': 'مؤكد',
      'status_cancelled': 'ملغى',
      'status_completed': 'مكتمل',
      'filter_all': 'الكل',
      'filter_pending': 'جديدة',
      'filter_confirmed': 'مؤكدة',
      'filter_cancelled': 'ملغاة',
      'filter_completed': 'مكتملة',
      'summer_garden': 'جلسة صيفية',
      'winter_lounge': 'جلسة شتوية',
      'seating_any': 'أي مكان متاح',
      'whatsapp_chat': 'تواصل عبر الواتساب',
      'call_now': 'اتصال تلفوني',
      'confirm_booking': 'تأكيد الحجز',
      'cancel_booking': 'إلغاء الحجز',
      'complete_booking': 'تعليم كمكتمل',
      'no_bookings': 'لا توجد حجوزات في هذه القائمة حالياً',

      // Settings
      'admin_settings': 'إعدادات اللوحة والأمان',
      'restaurant_phone': 'رقم واتساب المطعم للتواصل',
      'enable_bookings': 'تفعيل استقبال الحجوزات الإلكترونية',
      'change_pin': 'تغيير رمز PIN الدخول',
      'old_pin': 'رمز PIN الحالي',
      'new_pin': 'رمز PIN الجديد (4 أرقام)',
      'confirm_new_pin': 'تأكيد رمز PIN الجديد',
      'pin_changed_success': 'تم تغيير رمز الـ PIN بنجاح',
      'pin_mismatch': 'رمز PIN الجديد غير متطابق',
      'invalid_old_pin': 'رمز PIN الحالي غير صحيح',
      'save_changes': 'حفظ التغييرات',
      'saved_successfully': 'تم حفظ التغييرات بنجاح',

      // General Buttons & Messages
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'confirm': 'تأكيد',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ ما، يرجى المحاولة مرة أخرى',
      'delete_confirm_title': 'تأكيد الحذف',
      'delete_confirm_msg': 'هل أنت متأكد من محو هذا العنصر بشكل دائم؟',
      'no_data': 'لا توجد بيانات متاحة',
      'language': 'اللغة / Language',
    },
    'en': {
      'app_title': 'Krm Alteen - Admin Dashboard',
      'restaurant_name': 'Krm Alteen',
      'login_title': 'Admin Control Login',
      'enter_pin': 'Enter 4-digit PIN code',
      'invalid_pin': 'Invalid PIN code, please try again',
      'logout': 'Logout',

      // Navigation
      'nav_overview': 'Overview',
      'nav_menu': 'Menu & Categories',
      'nav_bookings': 'Bookings',
      'nav_settings': 'Settings & Security',

      // Overview
      'total_categories': 'Total Categories',
      'total_menu_items': 'Total Menu Items',
      'total_bookings': 'Total Bookings',
      'pending_bookings': 'Pending Bookings',
      'recent_bookings': 'Recent Bookings',
      'quick_actions': 'Quick Actions',

      // Menu & Categories
      'categories': 'Categories',
      'menu_items': 'Menu Items',
      'add_category': 'Add Category',
      'edit_category': 'Edit Category',
      'delete_category': 'Delete Category',
      'category_name_ar': 'Category Name (Arabic)',
      'category_name_en': 'Category Name (English)',
      'sort_order': 'Display Order',
      'add_item': 'Add Menu Item',
      'edit_item': 'Edit Menu Item',
      'delete_item': 'Delete Menu Item',
      'item_name_ar': 'Item Name (Arabic)',
      'item_name_en': 'Item Name (English)',
      'desc_ar': 'Description (Arabic)',
      'desc_en': 'Description (English)',
      'price_syp': 'Price (SYP)',
      'select_category': 'Select Category',
      'tags_comma': 'Tags (comma separated e.g.: Fresh, Popular)',
      'available': 'Available',
      'unavailable': 'Currently Unavailable',
      'upload_image': 'Upload Image',
      'change_image': 'Change Image',
      'image_required': 'Please select an image for this item',
      'search_placeholder': 'Search menu item by name...',
      'all_categories': 'All Categories',
      'category_delete_error_title': 'Cannot Delete Category',
      'category_delete_error_msg': 'Cannot delete this category because it contains {count} items. Please remove or move those items first.',

      // Bookings
      'booking_id': 'Booking ID',
      'customer_name': 'Customer Name',
      'phone_number': 'Phone Number',
      'guests_count': 'Guests',
      'booking_date': 'Booking Date',
      'booking_time': 'Booking Time',
      'seating_preference': 'Seating Preference',
      'special_requests': 'Special Requests',
      'status': 'Status',
      'status_pending': 'Pending',
      'status_confirmed': 'Confirmed',
      'status_cancelled': 'Cancelled',
      'status_completed': 'Completed',
      'filter_all': 'All',
      'filter_pending': 'Pending',
      'filter_confirmed': 'Confirmed',
      'filter_cancelled': 'Cancelled',
      'filter_completed': 'Completed',
      'summer_garden': 'Summer Garden',
      'winter_lounge': 'Winter Lounge',
      'seating_any': 'Any Available Table',
      'whatsapp_chat': 'WhatsApp Chat',
      'call_now': 'Call Customer',
      'confirm_booking': 'Confirm Booking',
      'cancel_booking': 'Cancel Booking',
      'complete_booking': 'Mark as Completed',
      'no_bookings': 'No bookings found in this section',

      // Settings
      'admin_settings': 'Dashboard Settings & Security',
      'restaurant_phone': 'Restaurant WhatsApp Phone',
      'enable_bookings': 'Enable Online Bookings',
      'change_pin': 'Change Admin PIN',
      'old_pin': 'Current PIN',
      'new_pin': 'New PIN (4 digits)',
      'confirm_new_pin': 'Confirm New PIN',
      'pin_changed_success': 'PIN updated successfully',
      'pin_mismatch': 'New PIN entries do not match',
      'invalid_old_pin': 'Current PIN is incorrect',
      'save_changes': 'Save Changes',
      'saved_successfully': 'Settings saved successfully',

      // General
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'loading': 'Loading...',
      'error': 'An error occurred, please try again',
      'delete_confirm_title': 'Confirm Delete',
      'delete_confirm_msg': 'Are you sure you want to permanently delete this item?',
      'no_data': 'No data available',
      'language': 'Language / اللغة',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) async {
    return AppLocalization(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
