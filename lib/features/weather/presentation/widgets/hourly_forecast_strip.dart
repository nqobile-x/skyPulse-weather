import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weather_model.dart';
import '../../../../core/constants/weather_icons.dart';

/// Horizontal scrolling strip showing hourly forecasts (next 24 hours).
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({super.key, required this.hourly});

  final List<HourlyWeather> hourly;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Filter to show the next 24 hours
    final upcoming = hourly.where((h) => h.time.isAfter(now)).take(24).toList();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: upcoming.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final hour = upcoming[index];
          final isNow = index == 0;

          return _HourlyItem(
            hour: hour,
            isNow: isNow,
          );
        },
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  const _HourlyItem({required this.hour, required this.isNow});

  final HourlyWeather hour;
  final bool isNow;

  @override
  Widget build(BuildContext context) {
    final accentColor = WeatherIcons.color(hour.weatherCode);

    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isNow
              ? [
                  accentColor.withValues(alpha: 0.3),
                  accentColor.withValues(alpha: 0.1),
                ]
              : [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.03),
                ],
        ),
        border: Border.all(
          color: isNow
              ? accentColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isNow ? 'Now' : DateFormat('HH:mm').format(hour.time),
            style: TextStyle(
              fontSize: 12,
              color: isNow
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              fontWeight: isNow ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Icon(
            WeatherIcons.icon(hour.weatherCode),
            size: 26,
            color: accentColor,
          ),
          Text(
            '${hour.temperature.round()}°',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hour.precipitationProbability > 0)
            Text(
              '${hour.precipitationProbability}%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
