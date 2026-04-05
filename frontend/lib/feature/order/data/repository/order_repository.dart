// lib/features/order/data/repositories/order_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/order_model.dart';

class OrderRepository {
  final _api = ApiClient().dio;

  Future<OrderModel> placeOrder({
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
    String? specialInstructions,
  }) async {
    try {
      final res = await _api.post(ApiConstants.orders, data: {
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        if (specialInstructions != null && specialInstructions.isNotEmpty)
          'specialInstructions': specialInstructions,
      });
      return OrderModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 10, String? status}) async {
    try {
      final res = await _api.get(ApiConstants.myOrders, queryParameters: {
        'page': page, 'limit': limit,
        if (status != null) 'status': status,
      });
      final list = res.data['data'] as List? ?? [];
      return list.map((o) => OrderModel.fromJson({'order': o})).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> getOrder(String id) async {
    try {
      final res = await _api.get('${ApiConstants.orders}/$id');
      return OrderModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> cancelOrder(String id, {String? reason}) async {
    try {
      final res = await _api.patch('${ApiConstants.orders}/$id/cancel', data: {
        if (reason != null) 'reason': reason,
      });
      return OrderModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
