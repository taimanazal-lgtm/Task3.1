import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/network/api_exceptions.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _weatherRepository;

  WeatherProvider({WeatherRepository? weatherRepository})
    : _weatherRepository = weatherRepository ?? WeatherRepository();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  String? _errorMessage;

  // Getters فقط — الـ UI بتقرا منها، ما بتقدر تعدلها مباشرة
  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      final result = await _weatherRepository.getWeather(
        latitude: latitude,
        longitude: longitude,
      );
      _weather = result;
      _status = WeatherStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = WeatherStatus.error;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }
}
