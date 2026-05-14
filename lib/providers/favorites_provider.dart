import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';
import '../services/product_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favService = FavoritesService();
  final ProductService _productService = ProductService();

  Set<String> _favoriteIds = {};
  List<Product> _favoriteProducts = [];
  StreamSubscription<Set<String>>? _sub;
  bool _loading = false;

  Set<String> get favoriteIds => _favoriteIds;
  List<Product> get favoriteProducts => _favoriteProducts;
  bool get loading => _loading;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void startListening(String uid) {
    _sub?.cancel();
    _sub = _favService.watchFavoriteIds(uid).listen((ids) async {
      _favoriteIds = ids;
      notifyListeners();
      final futures = ids.map(_productService.fetchById).toList();
      final results = await Future.wait(futures);
      _favoriteProducts = results.whereType<Product>().toList();
      notifyListeners();
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _favoriteIds = {};
    _favoriteProducts = [];
  }

  Future<void> toggleFavorite(String uid, String productId) async {
    await _favService.toggleFavorite(uid, productId);
  }

  Future<void> loadFavoriteProducts(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      final ids = await _favService.fetchFavoriteIds(uid);
      final futures = ids.map(_productService.fetchById).toList();
      final results = await Future.wait(futures);
      _favoriteProducts = results.whereType<Product>().toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
