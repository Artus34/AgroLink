import 'package:agrolink/features/market_info/weather/services/weather_service.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

import '../../market_info/weather/views/weather_screen.dart';

class WeatherDisplayCard extends StatelessWidget {
  final WeatherData weatherData;
  const WeatherDisplayCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final location = weatherData.location;

    return Card(
      elevation: 4.0,
      color: AppColors.lightCard,
      shadowColor: AppColors.primaryGreen.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeatherScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${current.tempC.round()}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https:${current.iconUrl}',
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.cloud_off, color: AppColors.textSecondary, size: 70),
                  ),
                  Text(
                    current.conditionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
