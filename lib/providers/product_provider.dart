import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/sub_subcategory.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  List<SubSubcategory> _subSubcategories = [];
  List<Product> _products = [];
  List<Product> _offers = [];
  bool _loadingCategories = false;
  bool _loadingShopTaxonomy = false;
  bool _loadingProducts = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Subcategory> get subcategories => _subcategories;
  List<SubSubcategory> get subSubcategories => _subSubcategories;
  List<Product> get products => _products;
  List<Product> get offers => _offers;
  bool get loadingCategories => _loadingCategories;
  bool get loadingShopTaxonomy => _loadingShopTaxonomy;
  bool get loadingProducts => _loadingProducts;
  String? get error => _error;

  List<Subcategory> subcategoriesFor(String categoryId) =>
      _subcategories.where((s) => s.categoryId == categoryId).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<SubSubcategory> subSubcategoriesFor(String subcategoryId) =>
      _subSubcategories.where((s) => s.subcategoryId == subcategoryId).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  Future<void> loadCategories() async {
    _loadingCategories = true;
    notifyListeners();
    try {
      _categories = await _service.fetchCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadShopTaxonomy() async {
    _loadingShopTaxonomy = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchCategories(),
        _service.fetchSubcategories(),
        _service.fetchSubSubcategories(),
      ]);
      _categories = results[0] as List<Category>;
      _subcategories = results[1] as List<Subcategory>;
      _subSubcategories = results[2] as List<SubSubcategory>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingShopTaxonomy = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({
    String? categoryId,
    String? subcategoryId,
    String? subSubcategoryId,
  }) async {
    _loadingProducts = true;
    notifyListeners();
    try {
      _products = await _service.fetchProducts(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        subSubcategoryId: subSubcategoryId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadOffers() async {
    try {
      _offers = await _service.fetchOffers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Product>> search(String query) async {
    if (query.isEmpty) return _products;
    return _service.searchProducts(query);
  }

  Future<Product?> fetchByBarcode(String barcode) async {
    return _service.fetchByBarcode(barcode);
  }
}
