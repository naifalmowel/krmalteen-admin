import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../core/services/firestore_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/notification_service.dart';
import 'categories_provider.dart';

final bookingStatusFilterProvider = StateProvider<String>((ref) => 'all');

final bookingsStreamProvider = StreamProvider<List<BookingModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);

  // Keep track of previous booking IDs to detect new incoming bookings
  final previousBookingIds = <String>{};
  var isFirstLoad = true;

  return firestoreService.getBookingsStream().map((bookings) {
    if (!isFirstLoad) {
      final currentIds = bookings.map((b) => b.id).toSet();
      final newBookings = bookings.where((b) =>
          !previousBookingIds.contains(b.id) && b.status == 'pending');

      if (newBookings.isNotEmpty) {
        AudioService.playNewBookingNotification();
        final latest = newBookings.first;
        NotificationService.showLocalNotification(
          title: 'حجز جديد من ${latest.fullName}',
          body: '${latest.guestsCount} أشخاص - ${latest.bookingDate} الساعة ${latest.bookingTime}',
        );
      }
      previousBookingIds.clear();
      previousBookingIds.addAll(currentIds);
    } else {
      previousBookingIds.addAll(bookings.map((b) => b.id));
      isFirstLoad = false;
    }

    return bookings;
  });
});

final filteredBookingsProvider = Provider<AsyncValue<List<BookingModel>>>((ref) {
  final bookingsAsync = ref.watch(bookingsStreamProvider);
  final filter = ref.watch(bookingStatusFilterProvider);

  return bookingsAsync.whenData((bookings) {
    if (filter == 'all') return bookings;
    return bookings.where((b) => b.status == filter).toList();
  });
});

final bookingActionsProvider = Provider<BookingActions>((ref) {
  return BookingActions(ref.watch(firestoreServiceProvider));
});

class BookingActions {
  final FirestoreService _firestoreService;

  BookingActions(this._firestoreService);

  Future<void> updateStatus(String bookingId, String status) async {
    await _firestoreService.updateBookingStatus(bookingId, status);
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _firestoreService.updateBooking(booking);
  }

  Future<void> addBooking(BookingModel booking) async {
    await _firestoreService.addBooking(booking);
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestoreService.deleteBooking(bookingId);
  }
}
