import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weather_model.dart';
import '../../../../core/constants/weather_icons.dart';

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.daily,
    required this.isCelsius,
  });

  final List<DailyWeather> daily;
  final bool isCelsius;

  @override
  Widget build(BuildContext context) {
    final allMax = daily.map((d) => d.temperatureMax).reduce((a, b) => a > b ? a : b);
    final allMin = daily.map((d) => d.temperatureMin).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          final maxTemp = isCelsius
              ? '${day.temperatureMax.round()}°'
              : '${_toF(day.temperatureMax).round()}°';
          final minTemp = isCelsius
              ? '${day.temperatureMin.round()}°'
              : '${_toF(day.temperatureMin).round()}°';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                // Day name
                SizedBox(
                  width: 52,
                  child: Text(
                    isToday ? 'Today' : DateFormat('EEE').format(day.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: isToday ? 1 : 0.75),
                      fontWeight:
                          isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                // Weather icon
                SizedBox(
                  width: 28,
                  child: Icon(
                    WeatherIcons.icon(day.weatherCode),
                    size: 18,
                    color: WeatherIcons.color(day.weatherCode),
                  ),
                ),
                // Precipitation
                SizedBox(
                  width: 38,
                  child: day.precipitationProbabilityMax > 0
                      ? Row(
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 10,
                              color: Colors.lightBlueAccent
                                  .withValues(alpha: 0.8),
                            ),
                            Text(
                              '${day.precipitationProbabilityMax}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.lightBlueAccent
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                // Min temp
                SizedBox(
                  width: 36,
                  child: Text(
                    minTemp,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.45),
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
                  width: 36,
                  child: Text(
                    maxTemp,
                    style: const TextStyle(
                      fontSize: 13,
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

  static double _toF(double c) => c * 9 / 5 + 32;
}

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
      height: 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final left = startFraction * totalWidth;
          final barWidth = (endFraction - startFraction) * totalWidth;

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              Positioned(
                left: left,
                child: Container(
                  width: barWidth.clamp(4.0, totalWidth),
                  height: 5,
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
