import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../data/weather_model.dart';
import '../data/weather_service.dart';
import '../data/location_model.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/hourly_forecast_strip.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/weather_detail_grid.dart';
import 'widgets/search_bar_widget.dart';

/// Main weather screen — the app's home page.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  WeatherData? _weather;
  String _cityName = 'Johannesburg';
  bool _isLoading = true;
  String? _error;

  // Default to Johannesburg
  double _lat = -26.2041;
  double _lon = 28.0473;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.getWeather(_lat, _lon);
      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoading = false;
        });
      }
    } on WeatherException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _onLocationSelected(LocationModel location) {
    setState(() {
      _cityName = location.name;
      _lat = location.latitude;
      _lon = location.longitude;
    });
    _fetchWeather();
  }

  /// Determine the gradient based on the current weather code.
  List<Color> _backgroundGradient(int weatherCode) {
    if (weatherCode <= 1) {
      // Clear sky
      return const [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)];
    } else if (weatherCode <= 3) {
      // Cloudy
      return const [Color(0xFF263238), Color(0xFF37474F), Color(0xFF455A64)];
    } else if (weatherCode <= 55 || (weatherCode >= 61 && weatherCode <= 67)) {
      // Rain / drizzle
      return const [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF1B3A4B)];
    } else if (weatherCode >= 71 && weatherCode <= 86) {
      // Snow
      return const [Color(0xFF37474F), Color(0xFF546E7A), Color(0xFF607D8B)];
    } else if (weatherCode >= 95) {
      // Thunderstorm
      return const [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)];
    }
    return const [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)];
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _weather != null
        ? _backgroundGradient(_weather!.current.weatherCode)
        : const [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: WeatherSearchBar(
                  weatherService: _weatherService,
                  onLocationSelected: _onLocationSelected,
                ),
              ),
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'Fetching weather...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchWeather,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final weather = _weather!;
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: _fetchWeather,
      color: Colors.white,
      backgroundColor: Colors.white24,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          // City name and date
          Center(
            child: Column(
              children: [
                Text(
                  _cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(now),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          // Current weather hero card
          CurrentWeatherCard(current: weather.current)
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 24),
          // Hourly forecast strip
          const _SectionTitle(title: 'Hourly Forecast'),
          const SizedBox(height: 8),
          HourlyForecastStrip(hourly: weather.hourly)
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          // Weather details grid
          const _SectionTitle(title: 'Details'),
          const SizedBox(height: 8),
          WeatherDetailGrid(
            current: weather.current,
            today: weather.daily.isNotEmpty ? weather.daily.first : null,
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
          const SizedBox(height: 24),
          // 7-day forecast
          const _SectionTitle(title: '7-Day Forecast'),
          const SizedBox(height: 8),
          DailyForecastList(daily: weather.daily)
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
