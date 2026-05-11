import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      _ResponseUnwrapper(),
      _AuthInterceptor(),
    ]);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    final response = await dio.get(path, queryParameters: params);
    return response.data;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final response = await dio.post(path, data: data);
    return response.data;
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    final response = await dio.put(path, data: data);
    return response.data;
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    final response = await dio.patch(path, data: data);
    return response.data;
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    final response = await dio.delete(path, data: data);
    return response.data;
  }

  Future<dynamic> postMultipart(String path, {required FormData formData}) async {
    final response = await dio.post(path, data: formData);
    return response.data;
  }
}

class _ResponseUnwrapper extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final json = response.data;
    if (json is Map<String, dynamic> && json.containsKey('code')) {
      if (json['code'] == 200) {
        response.data = json['data'];
        handler.next(response);
      } else {
        handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: json['message'] as String? ?? '请求失败',
        ));
      }
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        message = '连接超时，请检查网络';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败';
        break;
      case DioExceptionType.badResponse:
        message = _extractMessage(err.response?.data) ?? '服务器错误';
        break;
      default:
        message = err.message ?? '请求失败';
    }
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      message: message,
      error: err.error,
      type: err.type,
    ));
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) return data['message'] as String?;
    return null;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.token);
      await prefs.remove(StorageKeys.userInfo);
    }
    handler.next(err);
  }
}
