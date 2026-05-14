import 'package:cloud_firestore/cloud_firestore.dart';

class SubSubcategory {
  final String id;
  final String categoryId;
  final String subcategoryId;
  final String name;
  final String emoji;
  final String imageUrl;
  final int sortOrder;

  const SubSubcategory({
    required this.id,
    required this.categoryId,
    required this.subcategoryId,
    required this.name,
    required this.emoji,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory SubSubcategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubSubcategory(
      id: doc.id,
      categoryId: data['categoryId'] as String? ?? '',
      subcategoryId: data['subcategoryId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '💊',
      imageUrl: data['imageUrl'] as String? ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'name': name,
        'emoji': emoji,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      };
}
