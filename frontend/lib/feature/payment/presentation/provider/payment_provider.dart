// lib/features/payment/presentation/provider/payment_provider.dart

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/repositories/payment_repository.dart';
import '../../../../core/constants/api_constants.dart';

class PaymentProvider extends ChangeNotifier {
  final _repo = PaymentRepository();
  late Razorpay _razorpay;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void Function(String orderId)? _onSuccess;
  void Function(String message)? _onFailure;

  PaymentProvider() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> initiateRazorpayPayment({
    required BuildContext context,
    required String orderId,
    required String userEmail,
    required String userName,
    String? userPhone,
    required void Function(String orderId) onSuccess,
    required void Function(String message) onFailure,
  }) async {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repo.createPaymentOrder(orderId);

      final options = {
        'key': ApiConstants.razorpayKeyId,
        'amount': data['amount'],
        'currency': data['currency'] ?? 'INR',
        'name': 'FoodDash',
        'description': 'Order Payment - ${data['orderDetails']?['orderId'] ?? orderId}',
        'order_id': data['razorpayOrderId'],
        'prefill': {
          'contact': userPhone ?? '',
          'email': userEmail,
          'name': userName,
        },
        'theme': {'color': '#FF5722'},
        'external': {'wallets': ['paytm', 'phonepe', 'googlepay']},
      };

      _razorpay.open(options);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      onFailure(_error!);
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    try {
      await _repo.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        orderId: response.orderId ?? '',
      );
      _isLoading = false;
      notifyListeners();
      _onSuccess?.call(response.orderId ?? '');
    } catch (e) {
      _isLoading = false;
      _error = 'Payment verification failed';
      notifyListeners();
      _onFailure?.call(_error!);
    }
  }

  void _handleError(PaymentFailureResponse response) {
    _isLoading = false;
    _error = response.message ?? 'Payment failed';
    notifyListeners();
    _onFailure?.call(_error!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
