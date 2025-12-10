import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/dio_client.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');
    final email = prefs.getString('user_email');

    if (token != null && userId != null && email != null) {
      _user = UserModel(id: userId, email: email);
      DioClient().setAccessToken(token); // Update Dio headers
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signIn(email, password);
      _user = result['user'] as UserModel;
      final token = result['token'] as String;

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', _user!.id);
      await prefs.setString('user_email', _user!.email);

      // Update Dio
      DioClient().setAccessToken(token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(email, password);
      _isLoading = false;
      // Note: Usually signup requires email confirmation, so we don't login automatically yet
      // unless Supabase "Enable email confirmations" is OFF.
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    DioClient().setAccessToken(null); // Revert to anon key
    notifyListeners();
  }
}
