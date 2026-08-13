import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/weather_provider.dart';
import 'presentation/providers/city_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق الطقس',
      locale: const Locale('ar'),
      theme: ThemeData(
        primaryColor: const Color(0xFF1E8BF0),
        fontFamily: 'Cairo', // لو مضيفة خط عربي؛ احذفي السطر لو لأ
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
