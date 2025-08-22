// lib/features/predictions/fertilizer_recommendation/controllers/fertilizer_recommendation_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FertilizerRecommendationProvider extends ChangeNotifier {
  // Base URL for the FastAPI backend.
  // ➡️ Make sure this URL is correct for your deployed API.
  static const String _apiBaseUrl = 'https://agrofertilizer.onrender.com';

  bool _isLoading = false;
  String? _errorMessage;
  String? _recommendation;

  List<Map<String, dynamic>> _soilTypes = [];
  List<Map<String, dynamic>> _cropTypes = [];

  // Getters to expose the private variables
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get recommendation => _recommendation;
  List<Map<String, dynamic>> get soilTypes => _soilTypes;
  List<Map<String, dynamic>> get cropTypes => _cropTypes;

  // Method to fetch the categories (soil and crop types) from the API.
  Future<void> fetchCategories() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _soilTypes = List<Map<String, dynamic>>.from(data['soil_types']);
        _cropTypes = List<Map<String, dynamic>>.from(data['crop_types']);
      } else {
        _setErrorMessage('Failed to load categories. Please try again.');
      }
    } catch (e) {
      _setErrorMessage('Network error: Check your internet connection or server status.');
    } finally {
      _setLoading(false);
    }
  }

  // Method to send the data and get a fertilizer recommendation.
  Future<void> getFertilizerRecommendation(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    _resetRecommendation();

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _recommendation = responseData['recommended_fertilizer'];
      } else {
        // Handle errors from the API, including the 422 Unprocessable Content error.
        final errorData = json.decode(response.body);
        _setErrorMessage(errorData['detail'] ?? 'Failed to get recommendation.');
      }
    } catch (e) {
      _setErrorMessage('Network error: Could not connect to the server.');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods to manage state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetRecommendation() {
    _recommendation = null;
    notifyListeners();
  }

  void _resetRecommendation() {
    _recommendation = null;
    // We don't notify here to prevent a flicker during a new prediction.
  }
}