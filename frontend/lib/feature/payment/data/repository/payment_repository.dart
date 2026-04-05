// lib/features/payment/data/repositories/payment_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class PaymentRepository {
  final _api = ApiClient().dio;

  Future<Map<String, dynamic>> createPaymentOrder(String orderId) async {
    try {
      final res = await _api.post(ApiConstants.paymentCreateOrder, data: {'orderId': orderId});
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
  }) async {
    try {
      final res = await _api.post(ApiConstants.paymentVerify, data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'orderId': orderId,
      });
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
