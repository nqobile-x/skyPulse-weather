import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weather_model.dart';
import '../../../../core/constants/weather_icons.dart';

class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    super.key,
    required this.hourly,
    required this.isCelsius,
    required this.locationNow,
  });

  final List<HourlyWeather> hourly;
  final bool isCelsius;
  final DateTime locationNow;

  @override
  Widget build(BuildContext context) {
    final upcoming = hourly.where((h) => h.time.isAfter(locationNow)).take(24).toList();

    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: upcoming.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _HourlyItem(
            hour: upcoming[index],
            isNow: index == 0,
            isCelsius: isCelsius,
          );
        },
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  const _HourlyItem({
    required this.hour,
    required this.isNow,
    required this.isCelsius,
  });

  final HourlyWeather hour;
  final bool isNow;
  final bool isCelsius;

  @override
  Widget build(BuildContext context) {
    final accentColor = WeatherIcons.color(hour.weatherCode);
    final temp = isCelsius
        ? '${hour.temperature.round()}°'
        : '${_toF(hour.temperature).round()}°';

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isNow
              ? [
                  accentColor.withValues(alpha: 0.28),
                  accentColor.withValues(alpha: 0.08),
                ]
              : [
                  Colors.white.withValues(alpha: 0.09),
                  Colors.white.withValues(alpha: 0.03),
                ],
        ),
        border: Border.all(
          color: isNow
              ? accentColor.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isNow ? 'Now' : DateFormat('HH:mm').format(hour.time),
            style: TextStyle(
              fontSize: 11,
              color: isNow ? Colors.white : Colors.white.withValues(alpha: 0.55),
              fontWeight: isNow ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Icon(
            WeatherIcons.icon(hour.weatherCode),
            size: 24,
            color: accentColor,
          ),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hour.precipitationProbability > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 9,
                  color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 2),
                Text(
                  '${hour.precipitationProbability}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 13),
        ],
      ),
    );
  }

  static double _toF(double c) => c * 9 / 5 + 32;
}
