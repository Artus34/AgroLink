import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final WeatherService _weatherService = WeatherService();

  // ✅ FIX: Renamed this method to match what your HomeScreen is calling.
  Future<void> fetchWeatherForecast({String locationQuery = 'auto:ip', bool force = false}) async {
    // Avoid fetching again if data already exists, unless forced to refresh.
    if (_weatherData != null && !force) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    // Notify listeners immediately for a better refresh experience.
    if (force) notifyListeners();

    try {
      // The service method is correctly named `fetchWeather`
      _weatherData = await _weatherService.fetchWeather(locationQuery);
    } catch (e) {
      _errorMessage = "Failed to get weather. Check connection or API key.";
      debugPrint("WeatherProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

