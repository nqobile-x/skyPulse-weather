import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/weather/presentation/weather_screen.dart';

void main() {
  runApp(const WeatherApp());
}

/// Root application widget for the Weather App.
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyPulse Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const WeatherScreen(),
    );
  }
}
