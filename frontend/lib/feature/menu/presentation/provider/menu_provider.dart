// lib/features/menu/presentation/provider/menu_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/menu_model.dart';
import '../../data/repositories/menu_repository.dart';

enum MenuStatus { initial, loading, loaded, error }

class MenuProvider extends ChangeNotifier {
  final _repo = MenuRepository();

  List<MenuSection> _sections = [];
  MenuStatus _status = MenuStatus.initial;
  String? _error;
  String _currentRestaurantId = '';

  List<MenuSection> get sections => _sections;
  MenuStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MenuStatus.loading;

  Future<void> loadMenu(String restaurantId) async {
    if (_currentRestaurantId == restaurantId && _status == MenuStatus.loaded) return;
    _status = MenuStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _sections = await _repo.getMenu(restaurantId);
      _currentRestaurantId = restaurantId;
      _status = MenuStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = MenuStatus.error;
    }
    notifyListeners();
  }

  void refresh(String restaurantId) {
    _currentRestaurantId = '';
    loadMenu(restaurantId);
  }
}
