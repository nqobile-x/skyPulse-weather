import 'package:flutter/material.dart';
import '../../data/weather_model.dart';
import '../../../../core/constants/weather_icons.dart';

/// Hero card showing the current temperature and weather condition.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final accentColor = WeatherIcons.color(current.weatherCode);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weather icon
          Icon(
            WeatherIcons.icon(current.weatherCode),
            size: 72,
            color: accentColor,
          ),
          const SizedBox(height: 8),
          // Temperature
          Text(
            '${current.temperature.round()}°',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              height: 1,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          // Condition
          Text(
            WeatherIcons.description(current.weatherCode),
            style: TextStyle(
              fontSize: 18,
              color: accentColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Feels like
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: Text(
              'Feels like ${current.apparentTemperature.round()}°',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
