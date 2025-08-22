// lib/features/predictions/rainfall_prediction/controllers/rainfall_prediction_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RainfallPredictionProvider with ChangeNotifier {
  static const String _apiBaseUrl = 'https://agrorainfall.onrender.com';

  String? _predictedRainfall;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _subdivisions = [];

  String? get predictedRainfall => _predictedRainfall;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get subdivisions => _subdivisions;

  Future<void> fetchSubdivisions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/subdivisions'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _subdivisions = List<Map<String, dynamic>>.from(data);
      } else {
        _errorMessage = 'Failed to load subdivisions: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> predictRainfall({
    required int subdivisionId,
    required Map<String, double> rainfallData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _predictedRainfall = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'SUBDIVISION_ID': subdivisionId,
        ...rainfallData,
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _predictedRainfall = data['predicted_annual_rainfall_mm'];
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['detail'] ?? 'Prediction failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void resetPrediction() {
    _predictedRainfall = null;
    _errorMessage = null;
    notifyListeners();
  }
}