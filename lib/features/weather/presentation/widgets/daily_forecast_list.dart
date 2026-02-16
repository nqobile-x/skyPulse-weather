import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weather_model.dart';
import '../../../../core/constants/weather_icons.dart';

/// Vertical list showing the 7-day forecast.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key, required this.daily});

  final List<DailyWeather> daily;

  @override
  Widget build(BuildContext context) {
    // Find the global max/min for the temperature bar range
    final allMax = daily.map((d) => d.temperatureMax).reduce(
        (a, b) => a > b ? a : b);
    final allMin = daily.map((d) => d.temperatureMin).reduce(
        (a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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
        children: List.generate(daily.length, (index) {
          final day = daily[index];
          final isToday = index == 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Day name
                SizedBox(
                  width: 48,
                  child: Text(
                    isToday
                        ? 'Today'
                        : DateFormat('EEE').format(day.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(
                          alpha: isToday ? 1 : 0.8),
                      fontWeight:
                          isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                // Weather icon
                SizedBox(
                  width: 32,
                  child: Icon(
                    WeatherIcons.icon(day.weatherCode),
                    size: 20,
                    color: WeatherIcons.color(day.weatherCode),
                  ),
                ),
                // Precipitation probability
                SizedBox(
                  width: 36,
                  child: day.precipitationProbabilityMax > 0
                      ? Text(
                          '${day.precipitationProbabilityMax}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.lightBlueAccent
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // Min temp
                SizedBox(
                  width: 32,
                  child: Text(
                    '${day.temperatureMin.round()}°',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Temperature bar
                Expanded(
                  child: _TemperatureBar(
                    min: day.temperatureMin,
                    max: day.temperatureMax,
                    globalMin: allMin,
                    globalMax: allMax,
                  ),
                ),
                const SizedBox(width: 8),
                // Max temp
                SizedBox(
                  width: 32,
                  child: Text(
                    '${day.temperatureMax.round()}°',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Gradient temperature bar showing min–max range relative to global range.
class _TemperatureBar extends StatelessWidget {
  const _TemperatureBar({
    required this.min,
    required this.max,
    required this.globalMin,
    required this.globalMax,
  });

  final double min, max, globalMin, globalMax;

  @override
  Widget build(BuildContext context) {
    final range = globalMax - globalMin;
    final startFraction = range > 0 ? (min - globalMin) / range : 0.0;
    final endFraction = range > 0 ? (max - globalMin) / range : 1.0;

    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final left = startFraction * totalWidth;
          final barWidth =
              (endFraction - startFraction) * totalWidth;

          return Stack(
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              // Active bar
              Positioned(
                left: left,
                child: Container(
                  width: barWidth.clamp(4, totalWidth),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4FC3F7),
                        Color(0xFFFFD54F),
                        Color(0xFFFF8A65),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
