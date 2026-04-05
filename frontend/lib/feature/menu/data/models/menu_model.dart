// lib/features/menu/data/models/menu_model.dart

class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;

  MenuCategory({
    required this.id, required this.name, this.description,
    this.image, required this.sortOrder, required this.isActive,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    image: json['image'],
    sortOrder: json['sortOrder'] ?? 0,
    isActive: json['isActive'] ?? true,
  );
}

class CustomizationOption {
  final String groupName;
  final String selectedOption;
  final double additionalPrice;

  CustomizationOption({
    required this.groupName, required this.selectedOption, required this.additionalPrice,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) => CustomizationOption(
    groupName: json['groupName'] ?? '',
    selectedOption: json['selectedOption'] ?? '',
    additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'groupName': groupName,
    'selectedOption': selectedOption,
    'additionalPrice': additionalPrice,
  };
}

class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? discountedPrice;
  final String? image;
  final String categoryId;
  final String restaurantId;
  final bool isVeg;
  final bool isAvailable;
  final int sortOrder;
  final List<String> tags;

  MenuItem({
    required this.id, required this.name, this.description,
    required this.price, this.discountedPrice, this.image,
    required this.categoryId, required this.restaurantId,
    required this.isVeg, required this.isAvailable,
    required this.sortOrder, required this.tags,
  });

  double get effectivePrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  double get discountPercent => hasDiscount ? ((price - discountedPrice!) / price * 100) : 0;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    price: (json['price'] as num?)?.toDouble() ?? 0,
    discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
    image: json['image'],
    categoryId: json['category'] is Map ? json['category']['_id'] : (json['category'] ?? ''),
    restaurantId: json['restaurant'] is Map ? json['restaurant']['_id'] : (json['restaurant'] ?? ''),
    isVeg: json['isVeg'] ?? true,
    isAvailable: json['isAvailable'] ?? true,
    sortOrder: json['sortOrder'] ?? 0,
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class MenuSection {
  final MenuCategory category;
  final List<MenuItem> items;

  MenuSection({required this.category, required this.items});

  factory MenuSection.fromJson(Map<String, dynamic> json) => MenuSection(
    category: MenuCategory.fromJson(json['category'] ?? {}),
    items: (json['items'] as List? ?? []).map((i) => MenuItem.fromJson(i)).toList(),
  );
}
