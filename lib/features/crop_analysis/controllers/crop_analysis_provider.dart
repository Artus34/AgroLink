import 'package:flutter/material.dart';
import '../models/Price_data.dart';
import '../services/crop_analysis_service.dart';

class CropAnalysisProvider with ChangeNotifier {
  final CropAnalysisService _service = CropAnalysisService();

  List<PriceData> _priceData = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PriceData> get priceData => _priceData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPriceData({
    required int commodityId,
    required int stateId,
    List<int>? districtIds,
    List<int>? marketIds,
    required String fromDate,
    required String toDate,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedList = await _service.fetchPriceData(
        commodityId: commodityId,
        stateId: stateId,
        districtIds: districtIds,
        marketIds: marketIds,
        fromDate: fromDate,
        toDate: toDate,
      );
      _priceData = fetchedList;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
