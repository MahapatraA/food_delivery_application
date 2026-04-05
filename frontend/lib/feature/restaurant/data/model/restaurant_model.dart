// lib/features/restaurant/data/models/restaurant_model.dart

class RestaurantAddress {
  final String street, city, state, pincode;
  final double? lat, lng;

  RestaurantAddress({
    required this.street, required this.city,
    required this.state, required this.pincode, this.lat, this.lng,
  });

  factory RestaurantAddress.fromJson(Map<String, dynamic> json) => RestaurantAddress(
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
    lat: (json['coordinates']?['lat'] as num?)?.toDouble(),
    lng: (json['coordinates']?['lng'] as num?)?.toDouble(),
  );

  String get fullAddress => '$street, $city, $state - $pincode';
}

class RestaurantModel {
  final String id;
  final String name;
  final String? description;
  final List<String> cuisines;
  final RestaurantAddress address;
  final String phone;
  final String? logo;
  final List<String> images;
  final double rating;
  final int totalReviews;
  final double? priceForTwo;
  final int deliveryTime;
  final double minOrderAmount;
  final double deliveryFee;
  final bool isVeg;
  final bool isPureVeg;
  final bool isOpen;
  final bool isApproved;
  final String? offerText;
  final List<String> tags;

  RestaurantModel({
    required this.id, required this.name, this.description,
    required this.cuisines, required this.address, required this.phone,
    this.logo, required this.images, required this.rating,
    required this.totalReviews, this.priceForTwo, required this.deliveryTime,
    required this.minOrderAmount, required this.deliveryFee, required this.isVeg,
    required this.isPureVeg, required this.isOpen, required this.isApproved,
    this.offerText, required this.tags,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    cuisines: List<String>.from(json['cuisines'] ?? []),
    address: RestaurantAddress.fromJson(json['address'] ?? {}),
    phone: json['phone'] ?? '',
    logo: json['logo'],
    images: List<String>.from(json['images'] ?? []),
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalReviews: json['totalReviews'] ?? 0,
    priceForTwo: (json['priceForTwo'] as num?)?.toDouble(),
    deliveryTime: json['deliveryTime'] ?? 30,
    minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0,
    deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
    isVeg: json['isVeg'] ?? false,
    isPureVeg: json['isPureVeg'] ?? false,
    isOpen: json['isOpen'] ?? true,
    isApproved: json['isApproved'] ?? false,
    offerText: json['offerText'],
    tags: List<String>.from(json['tags'] ?? []),
  );
}
