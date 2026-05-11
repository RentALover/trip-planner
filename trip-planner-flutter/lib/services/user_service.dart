import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(client: ref.read(dioClientProvider));
});

class UserService {
  final DioClient client;
  UserService({required this.client});

  Future<UserProfile> getProfile() async {
    final data = await client.get('/user/profile');
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(UserUpdateReq req) async {
    final data = await client.put('/user/profile', data: req.toJson());
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword(PasswordChangeReq req) async {
    await client.put('/user/password', data: req.toJson());
  }

  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final data = await client.postMultipart('/upload/avatar', formData: formData);
    return data as String;
  }
}
