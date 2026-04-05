// lib/features/order/presentation/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/widgets.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../cart/presentation/provider/cart_provider.dart';
import '../../../payment/presentation/provider/payment_provider.dart';
import '../provider/order_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'razorpay';
  AddressModel? _selectedAddress;
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _instructCtrl = TextEditingController();
  bool _useNewAddress = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null && user.addresses.isNotEmpty) {
      _selectedAddress = user.addresses.first;
      _useNewAddress = false;
    }
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _instructCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _addressPayload {
    if (!_useNewAddress && _selectedAddress != null) {
      return _selectedAddress!.toJson();
    }
    return {
      'street': _streetCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
    };
  }

  bool get _isAddressValid {
    if (!_useNewAddress && _selectedAddress != null) return true;
    return _streetCtrl.text.isNotEmpty && _cityCtrl.text.isNotEmpty &&
        _stateCtrl.text.isNotEmpty && _pincodeCtrl.text.isNotEmpty;
  }

  Future<void> _placeOrder() async {
    if (!_isAddressValid) {
      AppUtils.showSnackBar(context, 'Please fill in delivery address', isError: true);
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    // 1. Place the order
    final order = await orderProvider.placeOrder(
      deliveryAddress: _addressPayload,
      paymentMethod: _paymentMethod,
      specialInstructions: _instructCtrl.text.trim(),
    );

    if (order == null) {
      if (mounted) AppUtils.showSnackBar(context, orderProvider.error ?? 'Failed to place order', isError: true);
      return;
    }

    // 2. If Razorpay, initiate payment
    if (_paymentMethod == 'razorpay') {
      final user = context.read<AuthProvider>().user;
      await paymentProvider.initiateRazorpayPayment(
        context: context,
        orderId: order.orderId,
        userEmail: user?.email ?? '',
        userName: user?.name ?? '',
        userPhone: user?.phone ?? '',
        onSuccess: (orderId) async {
          await cartProvider.clearCart();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
              (route) => route.isFirst,
            );
          }
        },
        onFailure: (msg) {
          if (mounted) AppUtils.showSnackBar(context, msg, isError: true);
        },
      );
    } else {
      // COD — go directly to success
      await cartProvider.clearCart();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final order = context.watch<OrderProvider>();
    final user = context.watch<AuthProvider>().user;
    final isLoading = order.isLoading || context.watch<PaymentProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Delivery Address ──────────────────────────────
            _SectionCard(
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  // Saved addresses
                  if (user != null && user.addresses.isNotEmpty) ...[
                    ...user.addresses.map((addr) => RadioListTile<AddressModel>(
                      value: addr,
                      groupValue: _useNewAddress ? null : _selectedAddress,
                      title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(addr.fullAddress, style: const TextStyle(fontSize: 12)),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() { _selectedAddress = v; _useNewAddress = false; }),
                    )),
                    const Divider(),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _useNewAddress,
                      title: const Text('Enter new address', style: TextStyle(fontWeight: FontWeight.w600)),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (_) => setState(() => _useNewAddress = true),
                    ),
                  ],
                  if (_useNewAddress || (user?.addresses.isEmpty ?? true)) ...[
                    const SizedBox(height: 8),
                    AppTextField(label: 'Street / House No.', controller: _streetCtrl),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'City', controller: _cityCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: AppTextField(label: 'State', controller: _stateCtrl)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppTextField(label: 'Pincode', controller: _pincodeCtrl, keyboardType: TextInputType.number),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Payment Method ────────────────────────────────
            _SectionCard(
              title: 'Payment Method',
              icon: Icons.payment_outlined,
              child: Column(
                children: [
                  _PaymentTile(
                    label: 'Razorpay (UPI / Card / Netbanking)',
                    value: 'razorpay',
                    selected: _paymentMethod,
                    icon: Icons.credit_card,
                    onTap: (v) => setState(() => _paymentMethod = v),
                  ),
                  _PaymentTile(
                    label: 'Cash on Delivery (COD)',
                    value: 'cod',
                    selected: _paymentMethod,
                    icon: Icons.money,
                    onTap: (v) => setState(() => _paymentMethod = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Special Instructions ──────────────────────────
            _SectionCard(
              title: 'Special Instructions',
              icon: Icons.notes_outlined,
              child: AppTextField(
                label: 'Any special instructions?',
                controller: _instructCtrl,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 16),

            // ── Order Summary ─────────────────────────────────
            _SectionCard(
              title: 'Order Summary',
              icon: Icons.receipt_outlined,
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: '₹${cart.subtotal.toStringAsFixed(0)}'),
                  _SummaryRow(label: 'Delivery', value: cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(0)}'),
                  if (cart.discount > 0) _SummaryRow(label: 'Discount', value: '-₹${cart.discount.toStringAsFixed(0)}', valueColor: AppColors.success),
                  if (cart.taxes > 0) _SummaryRow(label: 'Taxes', value: '₹${cart.taxes.toStringAsFixed(0)}'),
                  const Divider(height: 20),
                  _SummaryRow(label: 'Total', value: '₹${cart.total.toStringAsFixed(0)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: _paymentMethod == 'cod' ? 'Place Order (COD)' : 'Pay ₹${cart.total.toStringAsFixed(0)}',
              onPressed: _placeOrder,
              isLoading: isLoading,
              icon: _paymentMethod == 'cod' ? Icons.check : Icons.lock,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String label, value, selected;
  final IconData icon;
  final void Function(String) onTap;
  const _PaymentTile({required this.label, required this.value, required this.selected, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.06) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textPrimary))),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.valueColor, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: valueColor ?? AppColors.textPrimary)),
      ],
    ),
  );
}
