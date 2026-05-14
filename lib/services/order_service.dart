import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_order.dart';
import '../models/cart_item.dart';
import '../core/constants/app_constants.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppOrder> placeOrder({
    required String userId,
    required List<CartItem> items,
    required String address,
    required bool isFirstOrder,
  }) async {
    final subtotal = items.fold(0.0, (s, i) => s + i.totalPrice);
    final deliveryFee =
        subtotal >= AppConstants.freeShippingThreshold ? 0.0 : AppConstants.deliveryFee;
    final total = subtotal + deliveryFee;

    final basePoints = items.fold<int>(0, (s, i) => s + i.totalRewardPoints);
    final bonusPoints = isFirstOrder ? AppConstants.firstOrderRewardPoints : 0;
    final rewardPointsEarned = basePoints + bonusPoints;

    final orderItems = items
        .map((i) => OrderItem(
              productId: i.productId,
              productName: i.productName,
              imageUrl: i.imageUrl,
              price: i.price,
              quantity: i.quantity,
            ))
        .toList();

    final order = AppOrder(
      id: '',
      userId: userId,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: 'confirmed',
      address: address,
      rewardPointsEarned: rewardPointsEarned,
      isFirstOrder: isFirstOrder,
      createdAt: DateTime.now(),
    );

    final docRef = await _db.collection('orders').add(order.toFirestore());
    return AppOrder(
      id: docRef.id,
      userId: order.userId,
      items: order.items,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,
      status: order.status,
      address: order.address,
      rewardPointsEarned: order.rewardPointsEarned,
      isFirstOrder: order.isFirstOrder,
      createdAt: order.createdAt,
    );
  }

  Future<List<AppOrder>> fetchUserOrders(String userId) async {
    final snap = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(AppOrder.fromFirestore).toList();
  }
}
