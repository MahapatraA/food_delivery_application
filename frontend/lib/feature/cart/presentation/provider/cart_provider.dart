// lib/features/cart/presentation/provider/cart_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final _repo = CartRepository();

  CartModel? _cart;
  bool _isLoading = false;
  String? _error;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CartItem> get items => _cart?.items ?? [];
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _cart?.subtotal ?? 0;
  double get deliveryFee => _cart?.deliveryFee ?? 0;
  double get taxes => _cart?.taxes ?? 0;
  double get discount => _cart?.discount ?? 0;
  double get total => _cart?.total ?? 0;
  String? get couponCode => _cart?.couponCode;
  bool get isEmpty => items.isEmpty;

  int getItemQuantity(String menuItemId) {
    final match = items.where((i) => i.menuItemId == menuItemId);
    return match.isEmpty ? 0 : match.fold(0, (sum, i) => sum + i.quantity);
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cart = await _repo.getCart();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart({
    required String menuItemId, required String restaurantId, required BuildContext context,
    int quantity = 1, List<Map<String, dynamic>> customizations = const [],
  }) async {
    try {
      _cart = await _repo.addToCart(menuItemId: menuItemId, quantity: quantity, customizations: customizations);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateItem(String itemId, int quantity) async {
    try {
      _cart = await _repo.updateCartItem(itemId, quantity);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> removeFromCart(String menuItemId) async {
    // Find cart item id by menuItemId
    final cartItem = items.where((i) => i.menuItemId == menuItemId).firstOrNull;
    if (cartItem == null) return;
    try {
      _cart = await _repo.removeCartItem(cartItem.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> removeItemById(String cartItemId) async {
    try {
      _cart = await _repo.removeCartItem(cartItemId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> clearCart() async {
    try {
      await _repo.clearCart();
      _cart = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> applyCoupon(String code) async {
    try {
      _cart = await _repo.applyCoupon(code);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeCoupon() async {
    try {
      _cart = await _repo.removeCoupon();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
