/// API constants for Open-Meteo (free, no API key required).
class ApiConstants {
  ApiConstants._();

  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  /// Build the forecast URL for given coordinates.
  static String forecastUrl(double lat, double lon) =>
      '$weatherBaseUrl/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,weather_code,wind_speed_10m,wind_direction_10m,'
      'surface_pressure,uv_index'
      '&hourly=temperature_2m,weather_code,precipitation_probability'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'sunrise,sunset,uv_index_max,precipitation_probability_max'
      '&timezone=auto'
      '&forecast_days=7';

  /// Build the geocoding search URL.
  static String searchUrl(String query) =>
      '$geocodingBaseUrl/search?name=$query&count=5&language=en&format=json';
}
