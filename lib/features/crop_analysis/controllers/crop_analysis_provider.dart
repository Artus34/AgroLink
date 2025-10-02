import 'package:flutter/material.dart';
import '../models/commodity_model.dart';
import '../services/crop_analysis_service.dart';

class CropAnalysisProvider with ChangeNotifier {
  final CropAnalysisService _service = CropAnalysisService();

  List<Commodity> _commodities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Commodity> get commodities => _commodities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches the list of commodities and updates the state.
  Future<void> fetchCommodities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedList = await _service.fetchCommodities();
      _commodities = fetchedList;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Error in provider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Placeholder for future features (e.g., fetching price trends)
  Future<void> fetchPriceTrend(int commodityId) async {
    // Implement logic to fetch specific price trend data here
    // For now, it's a placeholder.
    print('Fetching price trend for commodity ID: $commodityId');
  }
}
