import 'package:dio/dio.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/errors/failures.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  Future<UserModel> signUp(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/v1/signup',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Depending on Supabase settings, this might return the user immediately
      // or just a message to check email.
      // If auto-confirm is off, we still get the user object but session might be null.
      
      if (response.data != null && (response.data['user'] != null || response.data['id'] != null)) {
         // handle weird varied responses from Supabase versions, usually 'user' key exists
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
      throw AuthFailure(e.response?.data['error_description'] ?? 'Login failed');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
