import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/weather_model.dart';
import '../data/weather_service.dart';
import '../data/location_model.dart';
import '../../ai/jarvis_weather_ai.dart';
import '../../../../core/services/aria_voice.dart';
import '../../../../core/constants/weather_icons.dart';
import 'widgets/hourly_forecast_strip.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/weather_detail_grid.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/weather_scene.dart';
import 'widgets/aria_panel.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  late final AriaVoice _aria;

  WeatherData? _weather;
  String _cityName = 'Johannesburg';
  bool _isLoading = true;
  String? _error;
  bool _isCelsius = true;

  double _lat = -26.2041;
  double _lon = 28.0473;

  List<AriaInsight> _insights = [];
  String _briefing = '';
  int _fetchVersion = 0; // incremented on every fetch; stale responses are discarded

  @override
  void initState() {
    super.initState();
    _aria = AriaVoice();
    _aria.init();
    _loadUnitPref();
  }

  @override
  void dispose() {
    unawaited(_aria.dispose()); // async cleanup; unawaited is intentional
    super.dispose();
  }

  Future<void> _loadUnitPref() async {
    final prefs = await SharedPreferences.getInstance();
    final celsius = prefs.getBool('isCelsius') ?? true;
    if (mounted) setState(() => _isCelsius = celsius);
    _fetchWeather();
  }

  Future<void> _saveUnitPref(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius', v);
  }

  void _toggleUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
      if (_weather != null) {
        _insights = AriaWeatherAI.analyze(_weather!, _cityName, _isCelsius);
        _briefing = AriaWeatherAI.generateBriefing(_weather!, _cityName, _isCelsius);
      }
    });
    _saveUnitPref(_isCelsius);
  }

  Future<void> _fetchWeather() async {
    // Stop any ongoing narration — stale voice over fresh data is confusing
    unawaited(_aria.stop());

    // Version stamp: if the user changes city mid-flight, this response is stale
    final version = ++_fetchVersion;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.getWeather(_lat, _lon);
      if (!mounted || version != _fetchVersion) return; // discard stale response
      final insights = AriaWeatherAI.analyze(weather, _cityName, _isCelsius);
      final briefing = AriaWeatherAI.generateBriefing(weather, _cityName, _isCelsius);
      setState(() {
        _weather = weather;
        _insights = insights;
        _briefing = briefing;
        _isLoading = false;
      });
    } on WeatherException catch (e) {
      if (mounted && version == _fetchVersion) {
        setState(() { _error = e.message; _isLoading = false; });
      }
    } catch (_) {
      if (mounted && version == _fetchVersion) {
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

  // ── Background colour keyed to condition ─────────────────────────────────

  Color _bgColor(int code) {
    if (code >= 95) return const Color(0xFF05060F);
    if (code >= 71 && code <= 77) return const Color(0xFF0D1520);
    if ((code >= 51 && code <= 82)) return const Color(0xFF070E1C);
    if (code <= 1) return const Color(0xFF050A1A);
    return const Color(0xFF080F1E);
  }

  // ── Temperature string ────────────────────────────────────────────────────

  String _fmtTemp(double c) => _isCelsius
      ? '${c.round()}°'
      : '${(c * 9 / 5 + 32).round()}°';

  String _fmtTempFull(double c) => _isCelsius
      ? '${c.round()}°C'
      : '${(c * 9 / 5 + 32).round()}°F';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final code = _weather?.current.weatherCode ?? 0;
    final bg = _bgColor(code);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // Search bar pinned at top (inside SafeArea)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: WeatherSearchBar(
                weatherService: _weatherService,
                onLocationSelected: _onLocationSelected,
              ),
            ),
          ),
          // Content
          Expanded(child: _buildContent(bg)),
        ],
      ),
    );
  }

  Widget _buildContent(Color bg) {
    if (_isLoading) return _loadingView();
    if (_error != null) return _errorView();
    return _dataView(bg);
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _loadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
                color: const Color(0xFFCE93D8), strokeWidth: 2),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 1100.ms),
          const SizedBox(height: 20),
          const Text(
            'ARIA is analysing atmospheric conditions...',
            style: TextStyle(
              color: Color(0xFF9575CD),
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main data layout ──────────────────────────────────────────────────────

  Widget _dataView(Color bg) {
    final weather = _weather!;
    final now = weather.locationNow;

    return RefreshIndicator(
      onRefresh: _fetchWeather,
      color: const Color(0xFFCE93D8),
      backgroundColor: Colors.white10,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Hero: animated weather scene + temperature overlay ────────────
          SliverToBoxAdapter(child: _heroSection(weather, bg)),

          // ── Scrollable content ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Hourly
                _SectionTitle(title: 'Hourly Forecast', icon: Icons.schedule_rounded),
                const SizedBox(height: 8),
                HourlyForecastStrip(
                  hourly: weather.hourly,
                  isCelsius: _isCelsius,
                  locationNow: now,
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                const SizedBox(height: 24),

                // ARIA
                _SectionTitle(title: 'ARIA Intelligence', icon: Icons.auto_awesome_rounded),
                const SizedBox(height: 8),
                AriaPanel(
                  insights: _insights,
                  briefing: _briefing,
                  voice: _aria,
                  city: _cityName,
                )
                    .animate()
                    .fadeIn(delay: 160.ms, duration: 550.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 24),

                // Details
                _SectionTitle(title: 'Atmospheric Details', icon: Icons.dashboard_rounded),
                const SizedBox(height: 8),
                WeatherDetailGrid(
                  current: weather.current,
                  today: weather.daily.isNotEmpty ? weather.daily.first : null,
                  isCelsius: _isCelsius,
                ).animate().fadeIn(delay: 220.ms, duration: 500.ms),

                const SizedBox(height: 24),

                // 7-day
                _SectionTitle(title: '7-Day Forecast', icon: Icons.calendar_month_rounded),
                const SizedBox(height: 8),
                DailyForecastList(daily: weather.daily, isCelsius: _isCelsius)
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 500.ms),

                const SizedBox(height: 36),

                // Footer
                Center(
                  child: Text(
                    'Open-Meteo · Local ${DateFormat("HH:mm").format(now)} · ${weather.timezone}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.22),
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero section ──────────────────────────────────────────────────────────

  Widget _heroSection(WeatherData weather, Color bg) {
    final size = MediaQuery.of(context).size;
    final heroH = size.height * 0.40;
    final current = weather.current;
    final code = current.weatherCode;

    return SizedBox(
      height: heroH,
      child: Stack(
        children: [
          // Animated weather scene (GPU, RepaintBoundary inside)
          Positioned.fill(
            child: WeatherScene(
              weatherCode: code,
              isDay: current.isDay,
            ),
          ),

          // Bottom gradient fade to bg colour
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    bg.withValues(alpha: 0.55),
                    bg,
                  ],
                  stops: const [0.0, 0.42, 0.78, 1.0],
                ),
              ),
            ),
          ),

          // Temperature + city overlay (bottom of hero)
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // City name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.white.withValues(alpha: 0.55)),
                    const SizedBox(width: 4),
                    Text(
                      _cityName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Temperature (hero number)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fmtTemp(current.temperature),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 88,
                        fontWeight: FontWeight.w200,
                        height: 0.95,
                        letterSpacing: -3,
                      ),
                    ),
                    // Unit toggle
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: GestureDetector(
                        onTap: _toggleUnit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            _isCelsius ? '°C' : '°F',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Condition
                Text(
                  WeatherIcons.description(code),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),

                // Feels like + humidity strip
                Text(
                  'Feels ${_fmtTempFull(current.apparentTemperature)} · ${current.humidity}% humidity',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white38),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
