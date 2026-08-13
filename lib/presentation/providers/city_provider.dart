import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/repositories/city_repository.dart';
import '../../core/network/api_exceptions.dart';

enum CitySearchStatus { initial, loading, success, error }

class CityProvider extends ChangeNotifier {
  final CityRepository _cityRepository;

  CityProvider({CityRepository? cityRepository})
    : _cityRepository = cityRepository ?? CityRepository();

  CitySearchStatus _status = CitySearchStatus.initial;
  List<CityModel> _cities = [];
  String? _errorMessage;

  CitySearchStatus get status => _status;
  List<CityModel> get cities => _cities;
  String? get errorMessage => _errorMessage;

  Future<void> searchCities(String query) async {
    // لو الحقل فاضي، رجعي للحالة الأولية بدون طلب API
    if (query.trim().isEmpty) {
      _status = CitySearchStatus.initial;
      _cities = [];
      notifyListeners();
      return;
    }

    _status = CitySearchStatus.loading;
    notifyListeners();

    try {
      final result = await _cityRepository.searchCities(query);
      _cities = result;
      _status = CitySearchStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CitySearchStatus.error;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _status = CitySearchStatus.error;
    }

    notifyListeners();
  }
}
