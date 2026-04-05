// lib/features/auth/data/repositories/auth_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _api = ApiClient().dio;

  Future<AuthResponse> register({
    required String name, required String email,
    required String password, String? phone, String role = 'user',
  }) async {
    try {
      final res = await _api.post(ApiConstants.register, data: {
        'name': name, 'email': email, 'password': password,
        if (phone != null) 'phone': phone, 'role': role,
      });
      final authRes = AuthResponse.fromJson(res.data);
      await ApiClient().saveTokens(authRes.accessToken, authRes.refreshToken);
      return authRes;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AuthResponse> login({required String email, required String password}) async {
    try {
      final res = await _api.post(ApiConstants.login, data: {'email': email, 'password': password});
      final authRes = AuthResponse.fromJson(res.data);
      await ApiClient().saveTokens(authRes.accessToken, authRes.refreshToken);
      return authRes;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final res = await _api.get(ApiConstants.me);
      return UserModel.fromJson(res.data['data']['user'] ?? res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout);
    } catch (_) {}
    await ApiClient().clearTokens();
  }

  Future<UserModel> updateProfile({String? name, String? phone}) async {
    try {
      final res = await _api.put(ApiConstants.updateProfile, data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });
      return UserModel.fromJson(res.data['data']['user'] ?? res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _api.put(ApiConstants.changePassword, data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> addAddress(Map<String, dynamic> address) async {
    try {
      final res = await _api.post(ApiConstants.addAddress, data: address);
      return UserModel.fromJson(res.data['data']['user'] ?? res.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
