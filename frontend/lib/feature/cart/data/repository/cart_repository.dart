// lib/features/cart/data/repositories/cart_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/cart_model.dart';

class CartRepository {
  final _api = ApiClient().dio;

  Future<CartModel?> getCart() async {
    try {
      final res = await _api.get(ApiConstants.cart);
      if (res.data['data']['cart'] == null) return null;
      return CartModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CartModel> addToCart({
    required String menuItemId, int quantity = 1, List<Map<String, dynamic>> customizations = const [],
  }) async {
    try {
      final res = await _api.post(ApiConstants.cartAdd, data: {
        'menuItemId': menuItemId, 'quantity': quantity,
        if (customizations.isNotEmpty) 'customizations': customizations,
      });
      return CartModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CartModel> updateCartItem(String itemId, int quantity) async {
    try {
      final res = await _api.put('${ApiConstants.cart}/item/$itemId', data: {'quantity': quantity});
      return CartModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CartModel> removeCartItem(String itemId) async {
    try {
      final res = await _api.delete('${ApiConstants.cart}/item/$itemId');
      return CartModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await _api.delete(ApiConstants.cart);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CartModel> applyCoupon(String couponCode) async {
    try {
      final res = await _api.post(ApiConstants.cartCoupon, data: {'couponCode': couponCode});
      return CartModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CartModel> removeCoupon() async {
    try {
      final res = await _api.delete(ApiConstants.cartCoupon);
      return CartModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
