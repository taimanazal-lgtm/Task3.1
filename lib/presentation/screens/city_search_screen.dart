import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../data/models/city_model.dart';
import '../providers/city_provider.dart';
import 'home_screen.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    // لو في Timer شغال من كتابة سابقة، الغيه
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // ابدئي Timer جديد
    _debounce = Timer(const Duration(milliseconds: 450), () {
      context.read<CityProvider>().searchCities(query);
    });
  }

  void _onCitySelected(CityModel city) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => HomeScreen(city: city)));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر مدينتك'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن مدينة...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<CityProvider>(
                builder: (context, cityProvider, child) {
                  switch (cityProvider.status) {
                    case CitySearchStatus.initial:
                      return const Center(
                        child: Text(
                          'ابدأي بالكتابة لتجد مدينة معينة',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );

                    case CitySearchStatus.loading:
                      return const Center(child: CircularProgressIndicator());

                    case CitySearchStatus.error:
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                cityProvider.errorMessage ?? 'حدث خطأ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<CityProvider>().searchCities(
                                    _controller.text,
                                  );
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      );

                    case CitySearchStatus.success:
                      if (cityProvider.cities.isEmpty) {
                        return const Center(child: Text('لا توجد نتائج'));
                      }
                      return ListView.separated(
                        itemCount: cityProvider.cities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = cityProvider.cities[index];
                          return ListTile(
                            onTap: () => _onCitySelected(city),
                            title: Text(
                              city.name,
                              textDirection: TextDirection.rtl,
                            ),
                            subtitle: Text(
                              city.country,
                              textDirection: TextDirection.rtl,
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
