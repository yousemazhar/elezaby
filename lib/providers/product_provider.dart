import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Category> _categories = [];
  List<Product> _products = [];
  List<Product> _offers = [];
  bool _loadingCategories = false;
  bool _loadingProducts = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get offers => _offers;
  bool get loadingCategories => _loadingCategories;
  bool get loadingProducts => _loadingProducts;
  String? get error => _error;

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

  Future<void> loadProducts({String? categoryId}) async {
    _loadingProducts = true;
    notifyListeners();
    try {
      _products = await _service.fetchProducts(categoryId: categoryId);
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
