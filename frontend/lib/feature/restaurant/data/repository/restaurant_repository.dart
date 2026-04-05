// lib/features/restaurant/data/repositories/restaurant_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/restaurant_model.dart';

class RestaurantRepository {
  final _api = ApiClient().dio;

  Future<List<RestaurantModel>> getRestaurants({
    int page = 1, int limit = 10, String? search,
    String? cuisine, String? city, String sort = '-rating',
  }) async {
    try {
      final res = await _api.get(ApiConstants.restaurants, queryParameters: {
        'page': page, 'limit': limit, 'sort': sort,
        if (search != null && search.isNotEmpty) 'search': search,
        if (cuisine != null) 'cuisine': cuisine,
        if (city != null) 'city': city,
      });
      final list = res.data['data']['restaurants'] as List? ?? [];
      return list.map((j) => RestaurantModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<RestaurantModel> getRestaurant(String id) async {
    try {
      final res = await _api.get('${ApiConstants.restaurants}/$id');
      return RestaurantModel.fromJson(res.data['data']['restaurant'] ?? res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double lat, required double lng, double radius = 5,
  }) async {
    try {
      final res = await _api.get(ApiConstants.nearbyRestaurants, queryParameters: {
        'lat': lat, 'lng': lng, 'radius': radius,
      });
      final list = res.data['data']['restaurants'] as List? ?? [];
      return list.map((j) => RestaurantModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
