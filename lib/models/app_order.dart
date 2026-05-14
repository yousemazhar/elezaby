import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromMap(Map<String, dynamic> data) => OrderItem(
        productId: data['productId'] as String? ?? '',
        productName: data['productName'] as String? ?? '',
        imageUrl: data['imageUrl'] as String? ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0,
        quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      );
}

class AppOrder {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final String address;
  final int rewardPointsEarned;
  final bool isFirstOrder;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.address,
    required this.rewardPointsEarned,
    required this.isFirstOrder,
    required this.createdAt,
  });

  factory AppOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = data['items'] as List? ?? [];
    return AppOrder(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      items: rawItems
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'pending',
      address: data['address'] as String? ?? '',
      rewardPointsEarned: (data['rewardPointsEarned'] as num?)?.toInt() ?? 0,
      isFirstOrder: data['isFirstOrder'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'status': status,
        'address': address,
        'rewardPointsEarned': rewardPointsEarned,
        'isFirstOrder': isFirstOrder,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
