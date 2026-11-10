import 'dart:convert';
import 'package:crypto/crypto.dart';

class AppHelpers {
  /// Hashes a 4-digit PIN string using SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Formats phone numbers cleanly for LTR display and WhatsApp API compatibility
  static String formatPhoneNumber(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+') && cleaned.startsWith('09')) {
      cleaned = '+963${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+') && cleaned.startsWith('9')) {
      cleaned = '+963$cleaned';
    }
    return cleaned;
  }

  /// Formats phone number for whatsapp `wa.me` link without `+` sign
  static String getWhatsAppCleanPhone(String rawPhone) {
    final formatted = formatPhoneNumber(rawPhone);
    return formatted.replaceAll('+', '').replaceAll(' ', '');
  }

  /// Generates the official WhatsApp message template for booking response
  static String generateWhatsAppBookingMessage({
    required String fullName,
    required int guestsCount,
    required String bookingDate,
    required String bookingTime,
    required String status, // 'confirmed' or 'cancelled'/'declined'
    required bool isArabic,
  }) {
    if (status == 'confirmed') {
      if (isArabic) {
        return 'أهلاً بك $fullName 🌿 تم تأكيد حجزك في استراحة كرم التين لـ $guestsCount أشخاص يوم $bookingDate الساعة $bookingTime. ننتظر زيارتكم بكل حب!';
      } else {
        return 'Hello $fullName 🌿 Your booking at Krm Alteen Lounge for $guestsCount guests on $bookingDate at $bookingTime has been CONFIRMED. We look forward to welcoming you!';
      }
    } else {
      if (isArabic) {
        return 'أهلاً بك $fullName. نعتذر منك لعدم توفر شواغر في الوقت المطلوب يوم $bookingDate. نرجو التواصل لتنسيق موعد آخر.';
      } else {
        return 'Hello $fullName. We apologize as there are no available tables for the requested time on $bookingDate. Please contact us to coordinate another date.';
      }
    }
  }

  /// Formats currency to Syrian Pounds (SYP)
  static String formatCurrencySYP(double amount, {required bool isArabic}) {
    final formattedAmount = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return isArabic ? '$formattedAmount ل.س' : '$formattedAmount SYP';
  }
}
