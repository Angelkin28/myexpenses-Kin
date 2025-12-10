import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    final url = dotenv.env['SUPABASE_URL']!;
    final key = dotenv.env['SUPABASE_KEY']!;

    _dio = Dio(
      BaseOptions(
        baseUrl: url,
        headers: {
          'apikey': key,
          'Authorization': 'Bearer $key', // Default auth header mostly for anon access initially
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add interceptors for logging or token management
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  void setAccessToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token'; // Update with User Token
    } else {
       final key = dotenv.env['SUPABASE_KEY']!;
      _dio.options.headers['Authorization'] = 'Bearer $key'; // Revert to Anon Key
    }
  }
}
