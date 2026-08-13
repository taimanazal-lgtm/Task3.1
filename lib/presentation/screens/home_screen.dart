import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/city_model.dart';
import '../../data/models/weather_model.dart';
import '../providers/weather_provider.dart';
import 'weekly_forecast_screen.dart';

class HomeScreen extends StatefulWidget {
  final CityModel city;

  const HomeScreen({super.key, required this.city});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  void _fetchWeather() {
    context.read<WeatherProvider>().fetchWeather(
      latitude: widget.city.latitude,
      longitude: widget.city.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          switch (weatherProvider.status) {
            case WeatherStatus.initial:
            case WeatherStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case WeatherStatus.error:
              return _buildErrorState(weatherProvider.errorMessage);

            case WeatherStatus.success:
              return _buildSuccessState(weatherProvider.weather!);
          }
        },
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message ?? 'حدث خطأ',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(WeatherModel weather) {
    return RefreshIndicator(
      onRefresh: () async => _fetchWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopCard(weather),
            _buildStatsRow(weather),
            _buildHourlyForecast(weather),
            _buildWeeklyButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(WeatherModel weather) {
    final current = weather.current;
    final weatherInfo = WeatherCodeMapper.map(current.weatherCode);

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.city.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${current.temperature.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              weatherInfo.description,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'أعلى ${weather.daily.tempMax[0].round()}° · أقل ${weather.daily.tempMin[0].round()}°',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(WeatherModel weather) {
    final current = weather.current;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(Icons.water_drop, 'رطوبة ${current.humidity}%'),
          _statItem(Icons.air, 'رياح ${current.windSpeed.round()}كم'),
          _statItem(Icons.speed, '${current.pressure.round()}hPa'),
          _statItem(Icons.wb_sunny, 'UV ${current.uvIndex.round()}'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHourlyForecast(WeatherModel weather) {
    final hourly = weather.hourly;
    final now = DateTime.now();

    int startIndex = hourly.time.indexWhere((t) => t.isAfter(now));
    if (startIndex == -1) startIndex = 0;
    if (startIndex > 0) startIndex -= 1;

    final endIndex = (startIndex + 6).clamp(0, hourly.time.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الساعات الجاية',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: endIndex - startIndex,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final index = startIndex + i;
                final time = hourly.time[index];
                final temp = hourly.temperature[index];
                final code = hourly.weatherCode[index];
                final info = WeatherCodeMapper.map(code);

                final label = i == 0
                    ? 'الآن'
                    : '${time.hour}${time.hour >= 12 ? 'م' : 'ص'}';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12)),
                    Icon(info.icon, color: AppColors.primary, size: 22),
                    Text(
                      '${temp.round()}°',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: OutlinedButton(
        onPressed: () {
          final weather = context.read<WeatherProvider>().weather;
          if (weather == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WeeklyForecastScreen(weather: weather),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary),
        ),
        child: const Text('عرض توقعات 7 أيام ←'),
      ),
    );
  }
}
