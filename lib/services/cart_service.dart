import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsRef(String uid) =>
      _db.collection('carts').doc(uid).collection('items');

  Stream<List<CartItem>> watchCart(String uid) {
    return _itemsRef(uid).snapshots().map(
          (snap) => snap.docs.map(CartItem.fromFirestore).toList(),
        );
  }

  Future<void> addToCart(String uid, Product product) async {
    final existing = await _itemsRef(uid)
        .where('productId', isEqualTo: product.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final current = (doc.data()['quantity'] as num?)?.toInt() ?? 1;
      await doc.reference.update({'quantity': current + 1});
    } else {
      await _itemsRef(uid).add({
        'productId': product.id,
        'productName': product.name,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'quantity': 1,
        'rewardPoints': product.rewardPoints,
        'addedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  Future<void> updateQuantity(String uid, String itemId, int quantity) async {
    if (quantity <= 0) {
      await _itemsRef(uid).doc(itemId).delete();
    } else {
      await _itemsRef(uid).doc(itemId).update({'quantity': quantity});
    }
  }

  Future<void> removeItem(String uid, String itemId) async {
    await _itemsRef(uid).doc(itemId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snap = await _itemsRef(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
