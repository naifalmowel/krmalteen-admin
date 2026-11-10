import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';

class AdminSettingsModel {
  final String pinHash;
  final String restaurantPhone;
  final bool isBookingEnabled;

  AdminSettingsModel({
    required this.pinHash,
    required this.restaurantPhone,
    required this.isBookingEnabled,
  });

  factory AdminSettingsModel.defaultSettings() {
    return AdminSettingsModel(
      pinHash: AppHelpers.hashPin(AppConstants.defaultPin),
      restaurantPhone: AppConstants.defaultRestaurantPhone,
      isBookingEnabled: true,
    );
  }

  factory AdminSettingsModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      return AdminSettingsModel.defaultSettings();
    }
    final data = doc.data() as Map<String, dynamic>;
    return AdminSettingsModel(
      pinHash: data['pinHash'] ?? AppHelpers.hashPin(AppConstants.defaultPin),
      restaurantPhone: data['restaurantPhone'] ?? AppConstants.defaultRestaurantPhone,
      isBookingEnabled: data['isBookingEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pinHash': pinHash,
      'restaurantPhone': restaurantPhone,
      'isBookingEnabled': isBookingEnabled,
    };
  }

  AdminSettingsModel copyWith({
    String? pinHash,
    String? restaurantPhone,
    bool? isBookingEnabled,
  }) {
    return AdminSettingsModel(
      pinHash: pinHash ?? this.pinHash,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      isBookingEnabled: isBookingEnabled ?? this.isBookingEnabled,
    );
  }
}
