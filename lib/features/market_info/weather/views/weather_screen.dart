import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/weather_provider.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldBackground,
      appBar: AppBar(
        title: const Text('Weather Details', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.lightCard,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.weatherData == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (provider.errorMessage != null && provider.weatherData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${provider.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ),
            );
          }

          if (provider.weatherData == null) {
            return const Center(child: Text('No weather data available.'));
          }

          final weatherData = provider.weatherData!;
          return RefreshIndicator(
            // ✅ FIX 1: Corrected method name and parameters to match the provider.
            onRefresh: () => Provider.of<WeatherProvider>(context, listen: false)
                .fetchWeatherForecast(locationQuery: weatherData.location.name, force: true),
            color: AppColors.primaryGreen,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                _CurrentWeatherHeader(current: weatherData.current, location: weatherData.location),
                const SizedBox(height: 24),
                _WeatherDetailsGrid(current: weatherData.current),
                const SizedBox(height: 24),
                _ForecastSection(forecastDays: weatherData.forecastDays),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS ---

class _CurrentWeatherHeader extends StatelessWidget {
  final Current current;
  final Location location;

  const _CurrentWeatherHeader({required this.current, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('${location.name}, ${location.region}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ FIX 2: Added 'https:' prefix to the icon URL.
                Image.network('https:${current.iconUrl}', width: 70, height: 70),
                const SizedBox(width: 16),
                Text('${current.tempC.round()}°C', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: AppColors.textPrimary)),
              ],
            ),
            Text(current.conditionText, style: const TextStyle(fontSize: 20, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetailsGrid extends StatelessWidget {
  final Current current;
  const _WeatherDetailsGrid({required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _DetailCard(icon: Icons.thermostat, label: 'Feels Like', value: '${current.feelslikeC.round()}°C'),
            _DetailCard(icon: Icons.air, label: 'Wind', value: '${current.windKph.round()} kph'),
            _DetailCard(icon: Icons.water_drop_outlined, label: 'Humidity', value: '${current.humidity}%'),
            _DetailCard(icon: Icons.grain, label: 'Precipitation', value: '${current.precipMm} mm'),
          ],
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastSection extends StatelessWidget {
  final List<ForecastDay> forecastDays;
  const _ForecastSection({required this.forecastDays});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('3-Day Forecast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Card(
          color: AppColors.lightCard,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            itemCount: forecastDays.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) => _ForecastTile(day: forecastDays[index]),
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        ),
      ],
    );
  }
}

class _ForecastTile extends StatelessWidget {
  final ForecastDay day;
  const _ForecastTile({required this.day});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // ✅ FIX 3: Added 'https:' prefix to the forecast icon URL.
      leading: Image.network('https:${day.iconUrl}', width: 40, height: 40),
      title: Text(day.dayOfWeek, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      subtitle: Text(day.conditionText, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: Text(
        '${day.maxTempC.round()}° / ${day.minTempC.round()}°',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }
}

