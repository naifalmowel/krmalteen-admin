import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final int sortOrder;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.sortOrder = 0,
    this.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      id: doc.id,
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'sortOrder': sortOrder,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
