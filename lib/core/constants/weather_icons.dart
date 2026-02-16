import 'package:flutter/material.dart';

/// Maps WMO weather codes to icons and descriptions.
class WeatherIcons {
  WeatherIcons._();

  static const Map<int, _WeatherInfo> _codes = {
    0: _WeatherInfo(Icons.wb_sunny_rounded, 'Clear sky', Color(0xFFFFD54F)),
    1: _WeatherInfo(Icons.wb_sunny_rounded, 'Mainly clear', Color(0xFFFFD54F)),
    2: _WeatherInfo(Icons.cloud_queue_rounded, 'Partly cloudy', Color(0xFF90CAF9)),
    3: _WeatherInfo(Icons.cloud_rounded, 'Overcast', Color(0xFF78909C)),
    45: _WeatherInfo(Icons.foggy, 'Foggy', Color(0xFFB0BEC5)),
    48: _WeatherInfo(Icons.foggy, 'Depositing rime fog', Color(0xFFB0BEC5)),
    51: _WeatherInfo(Icons.grain_rounded, 'Light drizzle', Color(0xFF81D4FA)),
    53: _WeatherInfo(Icons.grain_rounded, 'Moderate drizzle', Color(0xFF4FC3F7)),
    55: _WeatherInfo(Icons.grain_rounded, 'Dense drizzle', Color(0xFF29B6F6)),
    61: _WeatherInfo(Icons.water_drop_rounded, 'Slight rain', Color(0xFF4FC3F7)),
    63: _WeatherInfo(Icons.water_drop_rounded, 'Moderate rain', Color(0xFF29B6F6)),
    65: _WeatherInfo(Icons.water_drop_rounded, 'Heavy rain', Color(0xFF0288D1)),
    66: _WeatherInfo(Icons.ac_unit_rounded, 'Light freezing rain', Color(0xFF80DEEA)),
    67: _WeatherInfo(Icons.ac_unit_rounded, 'Heavy freezing rain', Color(0xFF4DD0E1)),
    71: _WeatherInfo(Icons.ac_unit_rounded, 'Slight snowfall', Color(0xFFE0E0E0)),
    73: _WeatherInfo(Icons.ac_unit_rounded, 'Moderate snowfall', Color(0xFFBDBDBD)),
    75: _WeatherInfo(Icons.ac_unit_rounded, 'Heavy snowfall', Color(0xFF9E9E9E)),
    77: _WeatherInfo(Icons.ac_unit_rounded, 'Snow grains', Color(0xFFE0E0E0)),
    80: _WeatherInfo(Icons.beach_access_rounded, 'Slight rain showers', Color(0xFF4FC3F7)),
    81: _WeatherInfo(Icons.beach_access_rounded, 'Moderate rain showers', Color(0xFF29B6F6)),
    82: _WeatherInfo(Icons.beach_access_rounded, 'Violent rain showers', Color(0xFF0277BD)),
    85: _WeatherInfo(Icons.ac_unit_rounded, 'Slight snow showers', Color(0xFFE0E0E0)),
    86: _WeatherInfo(Icons.ac_unit_rounded, 'Heavy snow showers', Color(0xFFBDBDBD)),
    95: _WeatherInfo(Icons.flash_on_rounded, 'Thunderstorm', Color(0xFFFFAB40)),
    96: _WeatherInfo(Icons.flash_on_rounded, 'Thunderstorm with slight hail', Color(0xFFFF9100)),
    99: _WeatherInfo(Icons.flash_on_rounded, 'Thunderstorm with heavy hail', Color(0xFFFF6D00)),
  };

  /// Get the icon for a WMO weather code.
  static IconData icon(int code) =>
      _codes[code]?.icon ?? Icons.help_outline_rounded;

  /// Get a human-readable description for a WMO weather code.
  static String description(int code) =>
      _codes[code]?.description ?? 'Unknown';

  /// Get the accent color for a WMO weather code.
  static Color color(int code) =>
      _codes[code]?.color ?? const Color(0xFF90A4AE);
}

class _WeatherInfo {
  const _WeatherInfo(this.icon, this.description, this.color);
  final IconData icon;
  final String description;
  final Color color;
}
