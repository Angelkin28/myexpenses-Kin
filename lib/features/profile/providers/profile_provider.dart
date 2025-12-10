import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/dio_client.dart';

class ProfileProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _profilePhotoUrl;
  String? _error;

  bool get isLoading => _isLoading;
  String? get profilePhotoUrl => _profilePhotoUrl;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get('/rest/v1/profiles');
      if (response.data != null &&
          response.data is List &&
          response.data.isNotEmpty) {
        _profilePhotoUrl = response.data[0]['profile_photo_url'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadProfilePhoto(File imageFile, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      // Update profile in database with base64 image
      final response = await _dioClient.dio.patch(
        '/rest/v1/profiles?id=eq.$userId',
        data: {'profile_photo_url': dataUrl},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _profilePhotoUrl = dataUrl;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      print('Error uploading photo: $e');
      print('Stack trace: ${StackTrace.current}');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
