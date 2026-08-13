import '../models/city_model.dart';
import '../services/geocoding_api_service.dart';

class CityRepository {
  final GeocodingApiService _geocodingApiService;

  CityRepository({GeocodingApiService? geocodingApiService})
    : _geocodingApiService = geocodingApiService ?? GeocodingApiService();

  Future<List<CityModel>> searchCities(String query) async {
    return await _geocodingApiService.searchCities(query);
  }
}
