import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String fullName;
  final String phone;
  final int guestsCount;
  final String bookingDate; // YYYY-MM-DD
  final String bookingTime; // e.g. "07:30 PM"
  final String seatingPreference; // 'summer_garden', 'winter_lounge', 'any'
  final String specialRequests;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.guestsCount,
    required this.bookingDate,
    required this.bookingTime,
    this.seatingPreference = 'any',
    this.specialRequests = '',
    this.status = 'pending',
    this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      guestsCount: (data['guestsCount'] as num?)?.toInt() ?? 1,
      bookingDate: data['bookingDate'] ?? '',
      bookingTime: data['bookingTime'] ?? '',
      seatingPreference: data['seatingPreference'] ?? 'any',
      specialRequests: data['specialRequests'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'phone': phone,
      'guestsCount': guestsCount,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'seatingPreference': seatingPreference,
      'specialRequests': specialRequests,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    int? guestsCount,
    String? bookingDate,
    String? bookingTime,
    String? seatingPreference,
    String? specialRequests,
    String? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      guestsCount: guestsCount ?? this.guestsCount,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      seatingPreference: seatingPreference ?? this.seatingPreference,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
