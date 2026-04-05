// lib/features/restaurant/presentation/screens/restaurant_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/widgets.dart';
import '../../data/models/restaurant_model.dart';
import '../../../menu/presentation/screens/menu_screen.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final RestaurantModel restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar with Image ──────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  restaurant.images.isNotEmpty || restaurant.logo != null
                      ? CachedNetworkImage(
                          imageUrl: restaurant.images.isNotEmpty ? restaurant.images.first : restaurant.logo!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _HeroPlaceholder(),
                        )
                      : _HeroPlaceholder(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  if (!restaurant.isOpen)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Text('RESTAURANT CLOSED', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 3)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + badges
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(restaurant.name, style: Theme.of(context).textTheme.headlineLarge),
                              const SizedBox(height: 4),
                              Text(restaurant.cuisines.join(' • '), style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        RatingBadge(rating: restaurant.rating),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${restaurant.totalReviews} ratings', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 20),

                    // Stats container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DetailStat(icon: Icons.access_time_outlined, label: 'Delivery', value: '${restaurant.deliveryTime} min'),
                          _Divider(),
                          _DetailStat(
                            icon: Icons.delivery_dining_outlined,
                            label: 'Delivery Fee',
                            value: restaurant.deliveryFee == 0 ? 'Free' : '₹${restaurant.deliveryFee.toStringAsFixed(0)}',
                            valueColor: restaurant.deliveryFee == 0 ? AppColors.success : null,
                          ),
                          _Divider(),
                          _DetailStat(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Min Order',
                            value: '₹${restaurant.minOrderAmount.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(restaurant.address.fullAddress, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (restaurant.description != null) ...[
                      const SizedBox(height: 16),
                      Text('About', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(restaurant.description!, style: Theme.of(context).textTheme.bodyMedium),
                    ],

                    if (restaurant.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: restaurant.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                        )).toList(),
                      ),
                    ],

                    const SizedBox(height: 32),
                    // Go to menu button
                    PrimaryButton(
                      text: 'Browse Menu',
                      icon: Icons.restaurant_menu,
                      onPressed: restaurant.isOpen
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MenuScreen(restaurant: restaurant)),
                            )
                          : null,
                    ),
                    if (!restaurant.isOpen) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'This restaurant is currently closed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.primary.withOpacity(0.1),
    child: const Icon(Icons.restaurant, size: 80, color: AppColors.primary),
  );
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _DetailStat({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: AppColors.primary, size: 22),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: AppColors.divider);
}
