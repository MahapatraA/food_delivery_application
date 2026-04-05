// lib/features/cart/presentation/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/widgets.dart';
import '../provider/cart_provider.dart';
import '../../../order/presentation/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (ok == true && mounted) cart.clearCart();
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : cart.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Add items from a restaurant to get started',
                  buttonText: 'Browse Restaurants',
                  onButton: () => Navigator.pop(context),
                )
              : _CartBody(cart: cart, couponCtrl: _couponCtrl),
      bottomNavigationBar: !cart.isEmpty
          ? _CheckoutBar(cart: cart)
          : null,
    );
  }
}

class _CartBody extends StatelessWidget {
  final CartProvider cart;
  final TextEditingController couponCtrl;
  const _CartBody({required this.cart, required this.couponCtrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Restaurant info
        if (cart.cart?.restaurant != null)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.store, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                      Text(cart.cart!.restaurant!.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Cart items
        const _SectionLabel(label: 'Items'),
        const SizedBox(height: 10),
        ...cart.items.map((item) => _CartItemCard(item: item)),

        const SizedBox(height: 16),

        // Coupon section
        _CouponSection(cart: cart, couponCtrl: couponCtrl),

        const SizedBox(height: 16),

        // Bill summary
        _BillSummary(cart: cart),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image != null
                ? CachedNetworkImage(
                    imageUrl: item.image, width: 60, height: 60, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _Thumb(),
                  )
                : _Thumb(),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('₹${item.price.toStringAsFixed(0)} each', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Qty control
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${item.itemTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyBtn(icon: Icons.remove, onTap: () {
                    if (item.quantity > 1) {
                      cartProvider.updateItem(item.id, item.quantity - 1);
                    } else {
                      cartProvider.removeItemById(item.id);
                    }
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  _QtyBtn(icon: Icons.add, onTap: () => cartProvider.updateItem(item.id, item.quantity + 1)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 60, height: 60, color: AppColors.primary.withOpacity(0.08),
    child: const Icon(Icons.fastfood, color: AppColors.primary, size: 24),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: AppColors.primary),
    ),
  );
}

class _CouponSection extends StatelessWidget {
  final CartProvider cart;
  final TextEditingController couponCtrl;
  const _CouponSection({required this.cart, required this.couponCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: cart.couponCode != null
          ? Row(
              children: [
                const Icon(Icons.local_offer, color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cart.couponCode!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.success)),
                      Text('You saved ₹${cart.discount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: cart.removeCoupon,
                  child: const Icon(Icons.close, color: AppColors.error, size: 20),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      prefixIcon: Icon(Icons.local_offer_outlined, color: AppColors.textLight),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (couponCtrl.text.trim().isEmpty) return;
                    final ok = await cart.applyCoupon(couponCtrl.text.trim());
                    if (!ok && context.mounted) {
                      AppUtils.showSnackBar(context, cart.error ?? 'Invalid coupon', isError: true);
                    } else {
                      couponCtrl.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
    );
  }
}

class _BillSummary extends StatelessWidget {
  final CartProvider cart;
  const _BillSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Bill Summary'),
          const SizedBox(height: 14),
          _BillRow(label: 'Subtotal', value: '₹${cart.subtotal.toStringAsFixed(0)}'),
          _BillRow(label: 'Delivery Fee', value: cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(0)}', valueColor: cart.deliveryFee == 0 ? AppColors.success : null),
          if (cart.taxes > 0) _BillRow(label: 'Taxes & Charges', value: '₹${cart.taxes.toStringAsFixed(0)}'),
          if (cart.discount > 0) _BillRow(label: 'Discount', value: '-₹${cart.discount.toStringAsFixed(0)}', valueColor: AppColors.success),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: AppColors.divider)),
          _BillRow(label: 'Total', value: '₹${cart.total.toStringAsFixed(0)}', isBold: true),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold;
  const _BillRow({required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary)),
          Text(value, style: TextStyle(fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _CheckoutBar extends StatelessWidget {
  final CartProvider cart;
  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: PrimaryButton(
        text: 'Proceed to Checkout  •  ₹${cart.total.toStringAsFixed(0)}',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
        icon: Icons.arrow_forward,
      ),
    );
  }
}
