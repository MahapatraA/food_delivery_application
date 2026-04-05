// lib/features/order/data/models/order_model.dart

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final double itemTotal;
  final String? image;

  OrderItem({required this.name, required this.price, required this.quantity, required this.itemTotal, this.image});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    name: json['name'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    quantity: json['quantity'] ?? 1,
    itemTotal: (json['itemTotal'] as num?)?.toDouble() ?? 0,
    image: json['image'],
  );
}

class OrderPayment {
  final String method;
  final String status;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime? paidAt;

  OrderPayment({required this.method, required this.status, this.razorpayOrderId, this.razorpayPaymentId, this.paidAt});

  factory OrderPayment.fromJson(Map<String, dynamic> json) => OrderPayment(
    method: json['method'] ?? '',
    status: json['status'] ?? '',
    razorpayOrderId: json['razorpayOrderId'],
    razorpayPaymentId: json['razorpayPaymentId'],
    paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
  );
}

class DeliveryAddress {
  final String street, city, state, pincode;

  DeliveryAddress({required this.street, required this.city, required this.state, required this.pincode});

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
  );

  Map<String, dynamic> toJson() => {'street': street, 'city': city, 'state': state, 'pincode': pincode};

  String get fullAddress => '$street, $city, $state - $pincode';
}

class OrderRestaurant {
  final String id;
  final String name;
  final String? logo;
  final String? phone;

  OrderRestaurant({required this.id, required this.name, this.logo, this.phone});

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) => OrderRestaurant(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    logo: json['logo'],
    phone: json['phone'],
  );
}

class OrderModel {
  final String id;
  final String orderId;
  final OrderRestaurant? restaurant;
  final List<OrderItem> items;
  final DeliveryAddress deliveryAddress;
  final OrderPayment payment;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final double total;
  final int estimatedDeliveryTime;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id, required this.orderId, this.restaurant, required this.items,
    required this.deliveryAddress, required this.payment, required this.status,
    required this.subtotal, required this.deliveryFee, required this.taxes,
    required this.discount, required this.total, required this.estimatedDeliveryTime,
    this.specialInstructions, required this.createdAt, this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final o = json['order'] ?? json;
    return OrderModel(
      id: o['_id'] ?? '',
      orderId: o['orderId'] ?? '',
      restaurant: o['restaurant'] != null && o['restaurant'] is Map ? OrderRestaurant.fromJson(o['restaurant']) : null,
      items: (o['items'] as List? ?? []).map((i) => OrderItem.fromJson(i)).toList(),
      deliveryAddress: DeliveryAddress.fromJson(o['deliveryAddress'] ?? {}),
      payment: OrderPayment.fromJson(o['payment'] ?? {}),
      status: o['status'] ?? 'pending',
      subtotal: (o['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (o['deliveryFee'] as num?)?.toDouble() ?? 0,
      taxes: (o['taxes'] as num?)?.toDouble() ?? 0,
      discount: (o['discount'] as num?)?.toDouble() ?? 0,
      total: (o['total'] as num?)?.toDouble() ?? 0,
      estimatedDeliveryTime: o['estimatedDeliveryTime'] ?? 30,
      specialInstructions: o['specialInstructions'],
      createdAt: DateTime.tryParse(o['createdAt'] ?? '') ?? DateTime.now(),
      deliveredAt: o['deliveredAt'] != null ? DateTime.tryParse(o['deliveredAt']) : null,
    );
  }
}
