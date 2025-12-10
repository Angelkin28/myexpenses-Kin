import 'package:dio/dio.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/errors/failures.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  Future<UserModel> signUp(String email, String password, String fullName) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/v1/signup',
        data: {
          'email': email,
          'password': password,
          'user_metadata': {
            'full_name': fullName,
          },
        },
      );
      
      if (response.data != null && (response.data['user'] != null || response.data['id'] != null)) {
         final userData = response.data['user'] ?? response.data;
         return UserModel.fromJson(userData);
      } else {
        throw ServerFailure('Unknown response structure during signup');
      }
    } on DioException catch (e) {
      throw AuthFailure(e.response?.data['msg'] ?? e.response?.data['error_description'] ?? 'Signup failed');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/v1/token?grant_type=password',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      final accessToken = data['access_token'];
      final user = UserModel.fromJson(data['user']);

      return {
        'token': accessToken,
        'user': user,
      };

    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data['error_description'] == 'Email not confirmed') {
        throw AuthFailure('Email not confirmed. Please verify your account.');
      }
      throw AuthFailure(e.response?.data['error_description'] ?? 'Login failed');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    try {
      await _dioClient.dio.post(
        '/auth/v1/verify',
        data: {
          'type': 'signup',
          'token': token,
          'email': email,
        },
      );
    } on DioException catch (e) {
      throw AuthFailure(e.response?.data['error_description'] ?? 'Verification failed');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
