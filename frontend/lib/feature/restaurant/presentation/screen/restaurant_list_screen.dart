// lib/features/restaurant/presentation/screens/restaurant_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/widgets.dart';
import '../../data/models/restaurant_model.dart';
import '../provider/restaurant_provider.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurants();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Kanpur, UP', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('What are you\ncraving today? 🍔', style: Theme.of(context).textTheme.headlineLarge),
                            ],
                          ),
                        ),
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      onChanged: provider.setSearch,
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, cuisines...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: AppColors.textLight),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  provider.setSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cuisine filter chips
                    if (provider.availableCuisines.isNotEmpty)
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'All',
                              selected: provider.selectedCuisine == null,
                              onTap: () => provider.setCuisine(null),
                            ),
                            ...provider.availableCuisines.map((c) => _FilterChip(
                              label: c,
                              selected: provider.selectedCuisine == c,
                              onTap: () => provider.setCuisine(c),
                            )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'Restaurants Near You',
                      actionText: provider.restaurants.isNotEmpty ? '${provider.restaurants.length} found' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────
            if (provider.isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const _RestaurantCardSkeleton(),
                    childCount: 5,
                  ),
                ),
              )
            else if (provider.status == RestaurantStatus.error)
              SliverFillRemaining(
                child: ErrorRetry(message: provider.error ?? 'Failed to load', onRetry: provider.loadRestaurants),
              )
            else if (provider.restaurants.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'No restaurants found',
                  subtitle: 'Try changing your search or filters',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RestaurantCard(restaurant: provider.restaurants[i]),
                    ),
                    childCount: provider.restaurants.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Restaurant Card ──────────────────────────────────────────────────────────
class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: restaurant)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: restaurant.images.isNotEmpty || restaurant.logo != null
                      ? CachedNetworkImage(
                          imageUrl: restaurant.images.isNotEmpty ? restaurant.images.first : restaurant.logo!,
                          height: 170, width: double.infinity, fit: BoxFit.cover,
                          placeholder: (_, __) => const ShimmerBox(width: double.infinity, height: 170, radius: 0),
                          errorWidget: (_, __, ___) => _PlaceholderImage(),
                        )
                      : _PlaceholderImage(),
                ),
                // Closed overlay
                if (!restaurant.isOpen)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: const Center(
                        child: Text('CLOSED', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 3)),
                      ),
                    ),
                  ),
                // Rating badge
                Positioned(
                  top: 12, left: 12,
                  child: RatingBadge(rating: restaurant.rating),
                ),
                // Veg badge
                if (restaurant.isPureVeg)
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.veg, borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('PURE VEG', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ),
                  ),
                // Offer text
                if (restaurant.offerText != null)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer, color: AppColors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            restaurant.offerText!,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info Section ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!restaurant.isApproved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Pending', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisines.join(' • '),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    children: [
                      _StatItem(icon: Icons.access_time_outlined, text: '${restaurant.deliveryTime} min'),
                      const SizedBox(width: 16),
                      _StatItem(
                        icon: Icons.delivery_dining_outlined,
                        text: restaurant.deliveryFee == 0 ? 'Free Delivery' : '₹${restaurant.deliveryFee.toStringAsFixed(0)} delivery',
                        color: restaurant.deliveryFee == 0 ? AppColors.success : null,
                      ),
                      const Spacer(),
                      if (restaurant.priceForTwo != null)
                        Text(
                          '₹${restaurant.priceForTwo!.toStringAsFixed(0)} for two',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Address + Go to menu button
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                restaurant.address.city,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: restaurant)),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Go to Menu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170, width: double.infinity,
      color: AppColors.primary.withOpacity(0.08),
      child: const Icon(Icons.restaurant, size: 60, color: AppColors.primary),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _StatItem({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color ?? AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RestaurantCardSkeleton extends StatelessWidget {
  const _RestaurantCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: double.infinity, height: 170, radius: 0),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 200, height: 18, radius: 6),
                const SizedBox(height: 8),
                ShimmerBox(width: 140, height: 13, radius: 6),
                const SizedBox(height: 12),
                Row(children: [
                  ShimmerBox(width: 80, height: 13, radius: 6),
                  const SizedBox(width: 16),
                  ShimmerBox(width: 100, height: 13, radius: 6),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
