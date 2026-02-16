import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weather_model.dart';

/// 2×3 grid showing weather details: wind, humidity, UV, pressure, sunrise/sunset.
class WeatherDetailGrid extends StatelessWidget {
  const WeatherDetailGrid({
    super.key,
    required this.current,
    this.today,
  });

  final CurrentWeather current;
  final DailyWeather? today;

  @override
  Widget build(BuildContext context) {
    final details = <_DetailItem>[
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${current.windSpeed.round()} km/h',
        subtitle: _windDirection(current.windDirection),
      ),
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${current.humidity}%',
        subtitle: _humidityLevel(current.humidity),
      ),
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        label: 'UV Index',
        value: current.uvIndex.toStringAsFixed(1),
        subtitle: _uvLevel(current.uvIndex),
      ),
      _DetailItem(
        icon: Icons.speed_rounded,
        label: 'Pressure',
        value: '${current.pressure.round()} hPa',
        subtitle: _pressureLevel(current.pressure),
      ),
      if (today != null) ...[
        _DetailItem(
          icon: Icons.wb_twilight_rounded,
          label: 'Sunrise',
          value: DateFormat('HH:mm').format(today!.sunrise),
          subtitle: 'Morning',
        ),
        _DetailItem(
          icon: Icons.nights_stay_outlined,
          label: 'Sunset',
          value: DateFormat('HH:mm').format(today!.sunset),
          subtitle: 'Evening',
        ),
      ],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final item = details[index];
        return _DetailCard(item: item);
      },
    );
  }

  String _windDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String _humidityLevel(int humidity) {
    if (humidity < 30) return 'Low';
    if (humidity < 60) return 'Moderate';
    return 'High';
  }

  String _uvLevel(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  String _pressureLevel(double pressure) {
    if (pressure < 1005) return 'Low';
    if (pressure < 1020) return 'Normal';
    return 'High';
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.item});

  final _DetailItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
