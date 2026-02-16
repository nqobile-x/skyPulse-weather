import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import 'weather_model.dart';
import 'location_model.dart';

/// Service responsible for fetching weather data from Open-Meteo.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Fetches current + 7-day forecast for the given coordinates.
  Future<WeatherData> getWeather(double lat, double lon) async {
    final url = ApiConstants.forecastUrl(lat, lon);
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw WeatherException(
        'Failed to fetch weather data (${response.statusCode})',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherData.fromJson(json);
  }

  /// Searches for locations matching the given query.
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final url = ApiConstants.searchUrl(Uri.encodeComponent(query.trim()));
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw WeatherException(
        'Failed to search locations (${response.statusCode})',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;

    if (results == null) return [];

    return results
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Custom exception for weather-related errors.
class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;

  @override
  String toString() => 'WeatherException: $message';
}
