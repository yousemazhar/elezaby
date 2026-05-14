import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final int rewardPoints;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.rewardPoints,
    required this.addedAt,
  });

  double get totalPrice => price * quantity;
  int get totalRewardPoints => rewardPoints * quantity;

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      rewardPoints: (data['rewardPoints'] as num?)?.toInt() ?? 0,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'rewardPoints': rewardPoints,
        'addedAt': Timestamp.fromDate(addedAt),
      };

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity ?? this.quantity,
        rewardPoints: rewardPoints,
        addedAt: addedAt,
      );
}
