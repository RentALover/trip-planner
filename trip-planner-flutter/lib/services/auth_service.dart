import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/storage_keys.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(client: ref.read(dioClientProvider));
});

class AuthService {
  final DioClient client;
  AuthService({required this.client});

  Future<LoginResponse> login(LoginReq req) async {
    final data = await client.post('/auth/login', data: req.toJson());
    final resp = LoginResponse.fromJson(data as Map<String, dynamic>);
    await _saveAuth(resp.token, resp.user);
    return resp;
  }

  Future<LoginResponse> register(RegisterReq req) async {
    final data = await client.post('/auth/register', data: req.toJson());
    final resp = LoginResponse.fromJson(data as Map<String, dynamic>);
    await _saveAuth(resp.token, resp.user);
    return resp;
  }

  Future<void> logout() async {
    try {
      await client.post('/auth/logout');
    } catch (_) {}
    await _clearAuth();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  Future<UserInfo?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(StorageKeys.userInfo);
    if (json == null) return null;
    // Parse simple JSON — UserInfo is stored as JSON string in SharedPreferences
    return null; // Will load via API instead
  }

  Future<void> _saveAuth(String token, UserInfo user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
    await prefs.setString(StorageKeys.userInfo,
      '{"id":${user.id},"username":"${user.username}","nickname":"${user.nickname}","avatarUrl":${user.avatarUrl != null ? '"${user.avatarUrl}"' : 'null'}}');
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.userInfo);
  }
}
