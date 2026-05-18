import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String subcategoryId;
  final String subSubcategoryId;
  final String barcode;
  final String activeIngredient;
  final String concentration;
  final String dosageForm;
  final String manufacturer;
  final String origin;
  final int stock;
  final int rewardPoints;
  final bool isOffer;
  final int? offerPercentage;
  final List<String> usageSteps;
  final String videoUrl;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.subcategoryId,
    required this.subSubcategoryId,
    required this.barcode,
    required this.activeIngredient,
    required this.concentration,
    required this.dosageForm,
    required this.manufacturer,
    required this.origin,
    required this.stock,
    required this.rewardPoints,
    required this.isOffer,
    this.offerPercentage,
    required this.usageSteps,
    this.videoUrl = '',
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      nameArabic: data['nameArabic'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      subcategoryId: data['subcategoryId'] as String? ?? '',
      subSubcategoryId: data['subSubcategoryId'] as String? ?? '',
      barcode: data['barcode'] as String? ?? '',
      activeIngredient: data['activeIngredient'] as String? ?? '',
      concentration: data['concentration'] as String? ?? '',
      dosageForm: data['dosageForm'] as String? ?? '',
      manufacturer: data['manufacturer'] as String? ?? '',
      origin: data['origin'] as String? ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      rewardPoints: (data['rewardPoints'] as num?)?.toInt() ?? 0,
      isOffer: data['isOffer'] as bool? ?? false,
      offerPercentage: (data['offerPercentage'] as num?)?.toInt(),
      usageSteps: List<String>.from(data['usageSteps'] as List? ?? []),
      videoUrl: data['videoUrl'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'nameArabic': nameArabic,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'subSubcategoryId': subSubcategoryId,
        'barcode': barcode,
        'activeIngredient': activeIngredient,
        'concentration': concentration,
        'dosageForm': dosageForm,
        'manufacturer': manufacturer,
        'origin': origin,
        'stock': stock,
        'rewardPoints': rewardPoints,
        'isOffer': isOffer,
        'offerPercentage': offerPercentage,
        'usageSteps': usageSteps,
        'videoUrl': videoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
