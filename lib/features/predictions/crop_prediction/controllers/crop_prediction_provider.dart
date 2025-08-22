// lib/features/predictions/crop_prediction/controllers/crop_prediction_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CropPredictionProvider with ChangeNotifier {
  String? _predictedCrop;
  bool _isLoading = false;
  String? _errorMessage;

  String? get predictedCrop => _predictedCrop;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> predictCrop({
    required double n,
    required double p,
    required double k,
    required double temperature,
    required double humidity,
    required double ph,
    required double rainfall,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _predictedCrop = null;
    notifyListeners();

    // The API URL to your Render backend.
    // If you have configured CORS on Render, you can use this direct URL.
    const String apiUrl = 'https://agrocrop-w45p.onrender.com/recommend';
    
    // If you are still troubleshooting CORS on Render, you can temporarily use a CORS proxy.
    // But it's best to fix the backend configuration permanently.
    // const String apiUrl = 'https://cors-anywhere.herokuapp.com/https://agrocrop-w45p.onrender.com/recommend';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'N': n,
          'P': p,
          'K': k,
          'temperature': temperature,
          'humidity': humidity,
          'ph': ph,
          'rainfall': rainfall,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Corrected key from 'prediction' to 'recommended_crop'
        _predictedCrop = data['recommended_crop']; 
      } else {
        _errorMessage = 'Failed to get a prediction. Status code: ${response.statusCode}. Body: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPrediction() {
    _predictedCrop = null;
    _errorMessage = null;
    notifyListeners();
  }
}