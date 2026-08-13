import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _weatherApiService;

  WeatherRepository({WeatherApiService? weatherApiService})
    : _weatherApiService = weatherApiService ?? WeatherApiService();

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    // هلق بس بينادي الـ Service، بس بكرا لو حبينا نضيف كاش
    // أو منطق تاني (مثلاً: تحقق من آخر وقت تحديث)، هون مكانه
    return await _weatherApiService.getWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
