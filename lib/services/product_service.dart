import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/sub_subcategory.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Category>> fetchCategories() async {
    final snap = await _db
        .collection('categories')
        .orderBy('sortOrder')
        .get();
    return snap.docs.map(Category.fromFirestore).toList();
  }

  Future<List<Subcategory>> fetchSubcategories({String? categoryId}) async {
    Query<Map<String, dynamic>> q = _db.collection('subcategories');
    if (categoryId != null) {
      q = q.where('categoryId', isEqualTo: categoryId);
    }
    final snap = await q.get();
    final list = snap.docs.map(Subcategory.fromFirestore).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<List<SubSubcategory>> fetchSubSubcategories({
    String? categoryId,
    String? subcategoryId,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('subsubcategories');
    if (subcategoryId != null) {
      q = q.where('subcategoryId', isEqualTo: subcategoryId);
    } else if (categoryId != null) {
      q = q.where('categoryId', isEqualTo: categoryId);
    }
    final snap = await q.get();
    final list = snap.docs.map(SubSubcategory.fromFirestore).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<List<Product>> fetchProducts({
    String? categoryId,
    String? subcategoryId,
    String? subSubcategoryId,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('products');
    if (subSubcategoryId != null) {
      q = q.where('subSubcategoryId', isEqualTo: subSubcategoryId);
    } else if (subcategoryId != null) {
      q = q.where('subcategoryId', isEqualTo: subcategoryId);
    } else if (categoryId != null) {
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

  Future<Map<String, List<String>>> fetchCategoryProductImages(
    List<String> categoryIds, {
    int perCategory = 3,
  }) async {
    final results = await Future.wait(categoryIds.map((id) async {
      final snap = await _db
          .collection('products')
          .where('categoryId', isEqualTo: id)
          .limit(perCategory)
          .get();
      final urls = snap.docs
          .map((d) => (d.data()['imageUrl'] as String?) ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
      return MapEntry(id, urls);
    }));
    return Map.fromEntries(results);
  }

  Future<Product?> fetchById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }
}
