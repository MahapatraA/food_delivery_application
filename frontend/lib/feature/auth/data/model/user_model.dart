// lib/features/auth/data/models/user_model.dart

class AddressModel {
  final String? id;
  final String label;
  final String street;
  final String city;
  final String state;
  final String pincode;

  AddressModel({
    this.id, required this.label, required this.street,
    required this.city, required this.state, required this.pincode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['_id'],
    label: json['label'] ?? 'Home',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'label': label, 'street': street, 'city': city,
    'state': state, 'pincode': pincode,
  };

  String get fullAddress => '$street, $city, $state - $pincode';
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profileImage;
  final List<AddressModel> addresses;
  final bool isActive;

  UserModel({
    required this.id, required this.name, required this.email,
    this.phone, required this.role, this.profileImage,
    required this.addresses, required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    role: json['role'] ?? 'user',
    profileImage: json['profileImage'],
    isActive: json['isActive'] ?? true,
    addresses: (json['addresses'] as List<dynamic>? ?? [])
        .map((a) => AddressModel.fromJson(a))
        .toList(),
  );

  bool get isRestaurantOwner => role == 'restaurant_owner';
  bool get isAdmin => role == 'admin';
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({required this.user, required this.accessToken, required this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] ?? {}),
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
    );
  }
}
