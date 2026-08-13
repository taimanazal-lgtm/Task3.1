import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/weather_model.dart';

class WeeklyForecastScreen extends StatelessWidget {
  final WeatherModel weather;

  const WeeklyForecastScreen({super.key, required this.weather});

  static const List<String> _dayNames = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  String _dayLabel(DateTime date, int index) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return 'اليوم';
    return _dayNames[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final daily = weather.daily;

    return Scaffold(
      appBar: AppBar(
        title: const Text('توقعات 7 أيام'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: daily.time.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final date = daily.time[index];
          final maxTemp = daily.tempMax[index];
          final minTemp = daily.tempMin[index];
          final code = daily.weatherCode[index];
          final info = WeatherCodeMapper.map(code);

          return ListTile(
            leading: Icon(info.icon, color: AppColors.primary, size: 26),
            title: Text(
              _dayLabel(date, index),
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              '${maxTemp.round()}° / ${minTemp.round()}°',
              style: const TextStyle(fontSize: 15),
            ),
          );
        },
      ),
    );
  }
}
