import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static bool _isInitialized = false;

  /// Initializes Supabase client with given URL and Key
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (url.isEmpty || anonKey.isEmpty || url.contains('YOUR_SUPABASE_URL')) {
      return;
    }
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
      _isInitialized = true;
    } catch (e) {
      _isInitialized = true; // Might already be initialized
    }
  }

  static bool get isInitialized => _isInitialized;

  /// Uploads image bytes to Supabase Storage in 'restaurant-menu' bucket and returns Public URL
  static Future<String> uploadMenuImage(
    Uint8List imageBytes,
    String fileName, {
    String mimeType = 'image/jpeg',
  }) async {
    final storage = Supabase.instance.client.storage.from(AppConstants.supabaseBucketName);
    final filePath = 'menu/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await storage.uploadBinary(
      filePath,
      imageBytes,
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: true,
      ),
    );

    final publicUrl = storage.getPublicUrl(filePath);
    return publicUrl;
  }
}
