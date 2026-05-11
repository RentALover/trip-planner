class ApiConstants {
  // Android emulator uses 10.0.2.2 to reach host localhost
  // iOS simulator uses localhost directly
  // Change this to your server's actual address for physical devices
  static const baseUrl = 'http://192.168.10.54:8080/api/v1';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
}
