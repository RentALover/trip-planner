class ApiConstants {
  // Android emulator uses 10.0.2.2 to reach host localhost
  // iOS simulator uses localhost directly
  // Change this to your server's actual address for physical devices
  static const baseUrl = 'https://trip-planner-server-9j09.onrender.com/api/v1';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
}
