import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _items = [];
  StreamSubscription<List<CartItem>>? _sub;
  bool _loading = false;

  List<CartItem> get items => _items;
  bool get loading => _loading;
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0.0, (s, i) => s + i.totalPrice);
  double get deliveryFee =>
      subtotal >= AppConstants.freeShippingThreshold ? 0.0 : AppConstants.deliveryFee;
  double get total => subtotal + deliveryFee;
  int get totalRewardPoints => _items.fold(0, (s, i) => s + i.totalRewardPoints);
  double get shippingProgress =>
      (subtotal / AppConstants.freeShippingThreshold).clamp(0.0, 1.0);
  double get amountUntilFreeShipping =>
      (AppConstants.freeShippingThreshold - subtotal).clamp(0.0, double.infinity);

  void startListening(String uid) {
    _sub?.cancel();
    _sub = _cartService.watchCart(uid).listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _items = [];
  }

  Future<void> addToCart(String uid, Product product) async {
    final previousItems = List<CartItem>.from(_items);
    _items = _optimisticAdd(product);
    _loading = true;
    notifyListeners();
    try {
      await _cartService.addToCart(uid, product);
    } catch (_) {
      _items = previousItems;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<CartItem> _optimisticAdd(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.productId == product.id);
    if (existingIndex == -1) {
      return [
        ..._items,
        CartItem(
          id: 'pending-${product.id}',
          productId: product.id,
          productName: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
          quantity: 1,
          rewardPoints: product.rewardPoints,
          addedAt: DateTime.now(),
        ),
      ];
    }

    return [
      for (var i = 0; i < _items.length; i++)
        if (i == existingIndex)
          _items[i].copyWith(quantity: _items[i].quantity + 1)
        else
          _items[i],
    ];
  }

  Future<void> updateQuantity(String uid, String itemId, int quantity) async {
    await _cartService.updateQuantity(uid, itemId, quantity);
  }

  Future<void> removeItem(String uid, String itemId) async {
    await _cartService.removeItem(uid, itemId);
  }

  Future<void> clearCart(String uid) async {
    await _cartService.clearCart(uid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
