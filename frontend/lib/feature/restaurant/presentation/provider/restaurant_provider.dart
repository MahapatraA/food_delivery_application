// lib/features/restaurant/presentation/provider/restaurant_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/restaurant_repository.dart';

enum RestaurantStatus { initial, loading, loaded, error }

class RestaurantProvider extends ChangeNotifier {
  final _repo = RestaurantRepository();

  List<RestaurantModel> _restaurants = [];
  RestaurantModel? _selectedRestaurant;
  RestaurantStatus _status = RestaurantStatus.initial;
  String? _error;
  String _searchQuery = '';
  String? _selectedCuisine;

  List<RestaurantModel> get restaurants => _filteredRestaurants;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  RestaurantStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == RestaurantStatus.loading;

  List<RestaurantModel> get _filteredRestaurants {
    var list = _restaurants;
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) =>
        r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.cuisines.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    if (_selectedCuisine != null) {
      list = list.where((r) => r.cuisines.contains(_selectedCuisine)).toList();
    }
    return list;
  }

  List<String> get availableCuisines {
    final set = <String>{};
    for (final r in _restaurants) set.addAll(r.cuisines);
    return set.toList()..sort();
  }

  Future<void> loadRestaurants() async {
    _status = RestaurantStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _restaurants = await _repo.getRestaurants();
      _status = RestaurantStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = RestaurantStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadRestaurant(String id) async {
    _status = RestaurantStatus.loading;
    notifyListeners();
    try {
      _selectedRestaurant = await _repo.getRestaurant(id);
      _status = RestaurantStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = RestaurantStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCuisine(String? cuisine) {
    _selectedCuisine = cuisine;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCuisine = null;
    notifyListeners();
  }
}
