import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weather_model.dart';

/// 2×N grid showing detailed weather metrics.
class WeatherDetailGrid extends StatelessWidget {
  const WeatherDetailGrid({
    super.key,
    required this.current,
    this.today,
    required this.isCelsius,
  });

  final CurrentWeather current;
  final DailyWeather? today;
  final bool isCelsius;

  @override
  Widget build(BuildContext context) {
    final visKm = current.visibility / 1000;

    final details = <_DetailItem>[
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${current.windSpeed.round()} km/h',
        subtitle: '${_windDir(current.windDirection)} · Gusts ${current.windGusts.round()}',
        color: const Color(0xFF90CAF9),
      ),
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${current.humidity}%',
        subtitle: _humidityLabel(current.humidity),
        color: const Color(0xFF4FC3F7),
      ),
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        label: 'UV Index',
        value: current.uvIndex.toStringAsFixed(1),
        subtitle: _uvLabel(current.uvIndex),
        color: const Color(0xFFFFD54F),
      ),
      _DetailItem(
        icon: Icons.speed_rounded,
        label: 'Pressure',
        value: '${current.pressure.round()} hPa',
        subtitle: _pressureLabel(current.pressure),
        color: const Color(0xFFCE93D8),
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: 'Visibility',
        value: visKm >= 10 ? '≥10 km' : '${visKm.toStringAsFixed(1)} km',
        subtitle: _visLabel(visKm),
        color: const Color(0xFF80CBC4),
      ),
      _DetailItem(
        icon: Icons.cloud_outlined,
        label: 'Cloud Cover',
        value: '${current.cloudCover}%',
        subtitle: _cloudLabel(current.cloudCover),
        color: const Color(0xFF90A4AE),
      ),
      if (today != null) ...[
        _DetailItem(
          icon: Icons.wb_twilight_rounded,
          label: 'Sunrise',
          value: DateFormat('HH:mm').format(today!.sunrise),
          subtitle: 'Morning golden hour',
          color: const Color(0xFFFFB74D),
        ),
        _DetailItem(
          icon: Icons.nights_stay_outlined,
          label: 'Sunset',
          value: DateFormat('HH:mm').format(today!.sunset),
          subtitle: 'Evening golden hour',
          color: const Color(0xFFFF8A65),
        ),
        if (today!.precipitationSum > 0)
          _DetailItem(
            icon: Icons.water_drop_rounded,
            label: 'Precipitation',
            value: '${today!.precipitationSum.toStringAsFixed(1)} mm',
            subtitle: today!.snowfallSum > 0
                ? '${today!.snowfallSum.toStringAsFixed(1)} mm snow'
                : '${today!.rainSum.toStringAsFixed(1)} mm rain',
            color: const Color(0xFF29B6F6),
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
        childAspectRatio: 1.65,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) => _DetailCard(item: details[index]),
    );
  }

  static String _windDir(int deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }

  static String _humidityLabel(int h) {
    if (h < 30) return 'Very dry';
    if (h < 45) return 'Comfortable';
    if (h < 60) return 'Moderate';
    if (h < 75) return 'Moist';
    return 'Very humid';
  }

  static String _uvLabel(double uv) {
    if (uv <= 2) return 'Low — no protection needed';
    if (uv <= 5) return 'Moderate — wear sunscreen';
    if (uv <= 7) return 'High — SPF 30+ required';
    if (uv <= 10) return 'Very High — seek shade';
    return 'Extreme — stay indoors';
  }

  static String _pressureLabel(double p) {
    if (p < 1000) return 'Very Low — storms likely';
    if (p < 1010) return 'Low — unsettled weather';
    if (p < 1020) return 'Normal — stable';
    if (p < 1030) return 'High — fair weather';
    return 'Very High — clear & dry';
  }

  static String _visLabel(double km) {
    if (km < 0.2) return 'Dense fog — very dangerous';
    if (km < 1) return 'Thick fog — dangerous';
    if (km < 4) return 'Moderate fog — caution';
    if (km < 10) return 'Haze or mist';
    return 'Clear visibility';
  }

  static String _cloudLabel(int cover) {
    if (cover < 10) return 'Clear sky';
    if (cover < 30) return 'Mostly clear';
    if (cover < 60) return 'Partly cloudy';
    if (cover < 85) return 'Mostly cloudy';
    return 'Overcast';
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
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
              Icon(item.icon, size: 14, color: item.color.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
