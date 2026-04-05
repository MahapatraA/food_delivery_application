// lib/features/menu/data/repositories/menu_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/menu_model.dart';

class MenuRepository {
  final _api = ApiClient().dio;

  Future<List<MenuSection>> getMenu(String restaurantId) async {
    try {
      final res = await _api.get('${ApiConstants.menu}/$restaurantId');
      final list = res.data['data']['menu'] as List? ?? [];
      return list.map((s) => MenuSection.fromJson(s)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MenuItem> getMenuItem(String id) async {
    try {
      final res = await _api.get('${ApiConstants.menuItems}/$id');
      return MenuItem.fromJson(res.data['data']['item'] ?? res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
