import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Category>> fetchCategories() async {
    final snap = await _db
        .collection('categories')
        .orderBy('sortOrder')
        .get();
    return snap.docs.map(Category.fromFirestore).toList();
  }

  Future<List<Product>> fetchProducts({String? categoryId}) async {
    Query<Map<String, dynamic>> q = _db.collection('products');
    if (categoryId != null) {
      q = q.where('categoryId', isEqualTo: categoryId);
    }
    final snap = await q.get();
    return snap.docs.map(Product.fromFirestore).toList();
  }

  Future<List<Product>> fetchOffers() async {
    final snap = await _db
        .collection('products')
        .where('isOffer', isEqualTo: true)
        .get();
    return snap.docs.map(Product.fromFirestore).toList();
  }

  Future<Product?> fetchByBarcode(String barcode) async {
    final snap = await _db
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Product.fromFirestore(snap.docs.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final all = await fetchProducts();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.nameArabic.toLowerCase().contains(q))
        .toList();
  }

  Future<Product?> fetchById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }
}
