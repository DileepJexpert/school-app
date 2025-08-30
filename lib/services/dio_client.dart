// lib/services/dio_client.dart
import 'package:dio/dio.dart';
import 'api_constants.dart';

class DioClient {
  // Private constructor
  DioClient._internal();

  // Singleton instance
  static final DioClient _instance = DioClient._internal();

  // Getter for the instance
  static DioClient get instance => _instance;

  // Dio object
  late Dio _dio;

  // Call this method from main.dart or your app's initialization logic
  static void initialize() {
    _instance._dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.add(LoggingInterceptor());
  }

  // Getter for the Dio instance
  Dio get dio => _dio;
}

// Interceptor for logging requests and responses, very useful for debugging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌍 REQUEST[${options.method}] => PATH: ${options.baseUrl}${options.path}');
    if (options.data != null) {
      print('   DATA: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ DIO ERROR[${err.response?.statusCode ?? 'N/A'}] => PATH: ${err.requestOptions.path}');
    if (err.response?.data != null) {
      print('   ERROR DATA: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
