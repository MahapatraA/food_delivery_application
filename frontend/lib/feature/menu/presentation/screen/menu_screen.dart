// lib/features/menu/presentation/screens/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/widgets.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../../../cart/presentation/provider/cart_provider.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../data/models/menu_model.dart';
import '../provider/menu_provider.dart';

class MenuScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const MenuScreen({super.key, required this.restaurant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _scrollCtrl = ScrollController();
  int _activeCategoryIndex = 0;
  final List<GlobalKey> _categoryKeys = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenu(widget.restaurant.id);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToCategory(int index) {
    setState(() => _activeCategoryIndex = index);
    if (index < _categoryKeys.length) {
      final ctx = _categoryKeys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();

    if (menuProvider.status == MenuStatus.loaded) {
      while (_categoryKeys.length < menuProvider.sections.length) {
        _categoryKeys.add(GlobalKey());
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : menuProvider.status == MenuStatus.error
              ? ErrorRetry(message: menuProvider.error ?? 'Failed', onRetry: () => menuProvider.refresh(widget.restaurant.id))
              : _buildBody(context, menuProvider, cartProvider),
      bottomNavigationBar: cartProvider.itemCount > 0 ? _CartBar(cartProvider: cartProvider) : null,
    );
  }

  Widget _buildBody(BuildContext context, MenuProvider menuProvider, CartProvider cartProvider) {
    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        // ── App Bar ──────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.restaurant.name, style: Theme.of(context).textTheme.titleLarge),
              Text(widget.restaurant.address.city, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
          bottom: menuProvider.sections.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    color: AppColors.surface,
                    child: SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: menuProvider.sections.length,
                        itemBuilder: (_, i) {
                          final isActive = _activeCategoryIndex == i;
                          return GestureDetector(
                            onTap: () => _scrollToCategory(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
                              ),
                              child: Text(
                                menuProvider.sections[i].category.name,
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : null,
        ),

        // ── Menu Sections ────────────────────────────────────
        if (menuProvider.sections.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.no_food_outlined,
              title: 'Menu is empty',
              subtitle: 'No items available for this restaurant',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, sectionIndex) {
                  final section = menuProvider.sections[sectionIndex];
                  return Column(
                    key: _categoryKeys.length > sectionIndex ? _categoryKeys[sectionIndex] : null,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category header
                      Container(
                        margin: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4, height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primary, borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(section.category.name, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(width: 8),
                            Text('(${section.items.length})', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      // Items grid
                      ...section.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MenuItemCard(item: item, restaurantId: widget.restaurant.id),
                      )),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 8),
                    ],
                  );
                },
                childCount: menuProvider.sections.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Menu Item Card ────────────────────────────────────────────────────────────
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String restaurantId;
  const MenuItemCard({super.key, required this.item, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final qty = cartProvider.getItemQuantity(item.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Info ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Veg badge + name
                  Row(
                    children: [
                      VegBadge(isVeg: item.isVeg),
                      const SizedBox(width: 8),
                      if (item.tags.contains('bestseller'))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('BESTSELLER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.orange, letterSpacing: 0.5)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (item.description != null)
                    Text(item.description!, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  // Price
                  Row(
                    children: [
                      Text(
                        '₹${item.effectivePrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12, color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.discountPercent.toStringAsFixed(0)}% off',
                            style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Right: Image + Add button ─────────────
            Column(
              children: [
                // Item image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.image != null
                      ? CachedNetworkImage(
                          imageUrl: item.image!,
                          width: 100, height: 100, fit: BoxFit.cover,
                          placeholder: (_, __) => const ShimmerBox(width: 100, height: 100, radius: 12),
                          errorWidget: (_, __, ___) => _ItemPlaceholder(),
                        )
                      : _ItemPlaceholder(),
                ),
                const SizedBox(height: 8),
                // Add to cart / qty control
                if (!item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Unavailable', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                  )
                else if (qty == 0)
                  _AddButton(onTap: () {
                    context.read<CartProvider>().addToCart(
                      menuItemId: item.id,
                      restaurantId: restaurantId,
                      context: context,
                    );
                    AppUtils.showSnackBar(context, '${item.name} added to cart');
                  })
                else
                  _QtyControl(
                    qty: qty,
                    onAdd: () => context.read<CartProvider>().addToCart(
                      menuItemId: item.id, restaurantId: restaurantId, context: context,
                    ),
                    onRemove: () => context.read<CartProvider>().removeFromCart(item.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 100, height: 100,
    color: AppColors.primary.withOpacity(0.08),
    child: const Icon(Icons.fastfood, color: AppColors.primary, size: 36),
  );
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text('ADD', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _QtyControl({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.primary, borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          GestureDetector(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart Bottom Bar ───────────────────────────────────────────────────────────
class _CartBar extends StatelessWidget {
  final CartProvider cartProvider;
  const _CartBar({required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${cartProvider.itemCount}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                Text(
                  '₹${cartProvider.total.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
