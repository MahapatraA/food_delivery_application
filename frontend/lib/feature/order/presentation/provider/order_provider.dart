// lib/features/order/presentation/provider/order_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final _repo = OrderRepository();

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<OrderModel?> placeOrder({
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
    String? specialInstructions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final order = await _repo.placeOrder(
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        specialInstructions: specialInstructions,
      );
      _currentOrder = order;
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMyOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _repo.getMyOrders();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadOrder(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentOrder = await _repo.getOrder(id);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> cancelOrder(String id, {String? reason}) async {
    try {
      final updated = await _repo.cancelOrder(id, reason: reason);
      final idx = _orders.indexWhere((o) => o.id == id);
      if (idx != -1) _orders[idx] = updated;
      if (_currentOrder?.id == id) _currentOrder = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setCurrentOrder(OrderModel order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
