// lib/features/cart/data/models/cart_model.dart

class CartItem {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final String? image;
  int quantity;
  final double itemTotal;

  CartItem({
    required this.id, required this.menuItemId, required this.name,
    required this.price, this.image, required this.quantity, required this.itemTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['_id'] ?? '',
    menuItemId: json['menuItem'] is Map ? json['menuItem']['_id'] : (json['menuItem'] ?? ''),
    name: json['name'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    image: json['image'],
    quantity: json['quantity'] ?? 1,
    itemTotal: (json['itemTotal'] as num?)?.toDouble() ?? 0,
  );
}

class CartRestaurant {
  final String id;
  final String name;
  final String? logo;
  final double deliveryFee;
  final double minOrderAmount;
  final bool isOpen;

  CartRestaurant({
    required this.id, required this.name, this.logo,
    required this.deliveryFee, required this.minOrderAmount, required this.isOpen,
  });

  factory CartRestaurant.fromJson(Map<String, dynamic> json) => CartRestaurant(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    logo: json['logo'],
    deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
    minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0,
    isOpen: json['isOpen'] ?? true,
  );
}

class CartModel {
  final String id;
  final CartRestaurant? restaurant;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final double total;
  final String? couponCode;

  CartModel({
    required this.id, this.restaurant, required this.items,
    required this.subtotal, required this.deliveryFee, required this.taxes,
    required this.discount, required this.total, this.couponCode,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final cart = json['cart'] ?? json;
    return CartModel(
      id: cart['_id'] ?? '',
      restaurant: cart['restaurant'] != null && cart['restaurant'] is Map
          ? CartRestaurant.fromJson(cart['restaurant'])
          : null,
      items: (cart['items'] as List? ?? []).map((i) => CartItem.fromJson(i)).toList(),
      subtotal: (cart['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (cart['deliveryFee'] as num?)?.toDouble() ?? 0,
      taxes: (cart['taxes'] as num?)?.toDouble() ?? 0,
      discount: (cart['discount'] as num?)?.toDouble() ?? 0,
      total: (cart['total'] as num?)?.toDouble() ?? 0,
      couponCode: cart['couponCode'],
    );
  }
}
