class AppConstants {
  // Firestore Collection Names
  static const String categoriesCollection = 'categories';
  static const String menuItemsCollection = 'menu_items';
  static const String bookingsCollection = 'bookings';
  static const String adminSettingsCollection = 'admin_settings';
  static const String adminConfigDocument = 'config';

  // Supabase Storage Config
  static const String supabaseBucketName = 'krm_alteen';
  
  // Supabase credentials placeholder/default. (User can also configure in Settings UI)
  static const String defaultSupabaseUrl = 'https://alujsfqvpvaapcfricld.supabase.co';
  static const String defaultSupabaseAnonKey = 'sb_publishable_fvJgI-3nslEB7HM6okev_Q_rfj0Lnry';

  // Security Defaults
  static const String defaultPin = '1234';

  // Restaurant Info
  static const String defaultRestaurantPhone = '+963 997 144 071';
}
