import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/app_order.dart';
import '../models/cart_item.dart';
import '../core/constants/app_constants.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<AppOrder> uploadPrescription({
    required String userId,
    required List<XFile> images,
    required String address,
    required String notes,
  }) async {
    if (images.isEmpty) {
      throw ArgumentError('At least one image is required');
    }

    final orderRef = _db.collection('orders').doc();
    const uuid = Uuid();

    final uploadFutures = <Future<String>>[];
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      final ext = image.name.contains('.') ? image.name.split('.').last : 'jpg';
      final ref = _storage
          .ref('prescriptions/$userId/${orderRef.id}/${uuid.v4()}_$i.$ext');
      uploadFutures.add(
        ref
            .putFile(File(image.path))
            .then((_) => ref.getDownloadURL()),
      );
    }
    final imageUrls = await Future.wait(uploadFutures);

    final createdAt = DateTime.now();
    final order = AppOrder(
      id: orderRef.id,
      userId: userId,
      items: const [],
      subtotal: 0,
      deliveryFee: 0,
      total: 0,
      status: 'pending',
      address: address,
      rewardPointsEarned: 0,
      isFirstOrder: false,
      createdAt: createdAt,
      type: 'prescription',
      prescriptionImages: imageUrls,
      notes: notes,
    );

    await orderRef.set(order.toFirestore());
    return order;
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
