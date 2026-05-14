import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('favorites').doc(uid).collection('items');

  Stream<Set<String>> watchFavoriteIds(String uid) {
    return _ref(uid).snapshots().map(
          (snap) => snap.docs
              .map((d) => d.data()['productId'] as String? ?? '')
              .toSet(),
        );
  }

  Future<void> toggleFavorite(String uid, String productId) async {
    final existing = await _ref(uid)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.delete();
    } else {
      await _ref(uid).add({
        'productId': productId,
        'addedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  Future<List<String>> fetchFavoriteIds(String uid) async {
    final snap = await _ref(uid).get();
    return snap.docs
        .map((d) => d.data()['productId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }
}
