import 'package:cloud_firestore/cloud_firestore.dart';

class Subcategory {
  final String id;
  final String categoryId;
  final String name;
  final String emoji;
  final String imageUrl;
  final int sortOrder;

  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory Subcategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subcategory(
      id: doc.id,
      categoryId: data['categoryId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '💊',
      imageUrl: data['imageUrl'] as String? ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'categoryId': categoryId,
        'name': name,
        'emoji': emoji,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      };
}
