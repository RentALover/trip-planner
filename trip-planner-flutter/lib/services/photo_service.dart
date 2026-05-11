import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/photo.dart';

final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService(client: ref.read(dioClientProvider));
});

class PhotoService {
  final DioClient client;
  PhotoService({required this.client});

  Future<List<PhotoAlbumItem>> listAll({int page = 1, int size = 20}) async {
    final data = await client.get('/photos', params: {'page': page, 'size': size});
    return (data as List<dynamic>).map((e) => PhotoAlbumItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Photo>> list(int tripId, {String? location, String? photoType, bool? featured}) async {
    final params = <String, dynamic>{};
    if (location != null) params['location'] = location;
    if (photoType != null) params['photoType'] = photoType;
    if (featured != null) params['featured'] = featured;
    final data = await client.get('/trips/$tripId/photos', params: params);
    return (data as List<dynamic>).map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> batchDelete(int tripId, List<int> ids) async {
    await client.delete('/trips/$tripId/photos/batch', data: {'ids': ids});
  }

  Future<List<Photo>> batchUpdate(int tripId, PhotoBatchUpdateReq req) async {
    final data = await client.put('/trips/$tripId/photos/batch', data: req.toJson());
    return (data as List<dynamic>).map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> delete(int tripId, int photoId) async {
    await client.delete('/trips/$tripId/photos/$photoId');
  }

  Future<Photo> toggleFeatured(int tripId, int photoId) async {
    final data = await client.patch('/trips/$tripId/photos/$photoId/featured');
    return Photo.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Photo>> uploadBatch(int tripId, List<String> filePaths, {String? location, String? photoType}) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(MapEntry('files', await MultipartFile.fromFile(path)));
    }
    if (location != null) formData.fields.add(MapEntry('location', location));
    if (photoType != null) formData.fields.add(MapEntry('photoType', photoType));
    final data = await client.postMultipart('/trips/$tripId/photos/batch', formData: formData);
    return (data as List<dynamic>).map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
  }
}
