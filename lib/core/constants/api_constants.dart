/// API constants for Open-Meteo (free, no API key required).
class ApiConstants {
  ApiConstants._();

  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1';

  static String forecastUrl(double lat, double lon) =>
      '$weatherBaseUrl/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,weather_code,wind_speed_10m,wind_direction_10m,'
      'surface_pressure,uv_index,cloud_cover,visibility,is_day,wind_gusts_10m'
      '&hourly=temperature_2m,weather_code,precipitation_probability,'
      'precipitation,wind_speed_10m,visibility'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'sunrise,sunset,uv_index_max,precipitation_probability_max,'
      'wind_speed_10m_max,wind_gusts_10m_max,precipitation_sum,'
      'rain_sum,snowfall_sum'
      '&timezone=auto'
      '&forecast_days=7';

  static String searchUrl(String query) =>
      '$geocodingBaseUrl/search?name=$query&count=5&language=en&format=json';
}
