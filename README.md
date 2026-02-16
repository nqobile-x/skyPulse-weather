# SkyPulse Weather

A modern, beautifully designed weather app built with Flutter. SkyPulse delivers real-time weather data with a premium dark UI, smooth animations, and an intuitive search experience.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![API](https://img.shields.io/badge/API-Open--Meteo-orange)

## Features

- **Real-Time Weather** — Current temperature, conditions, feels-like, and more
- **24-Hour Forecast** — Horizontally scrollable hourly forecast strip
- **7-Day Forecast** — Daily forecast with gradient temperature bars
- **Weather Details** — Wind speed, humidity, UV index, pressure, sunrise/sunset
- **City Search** — Autocomplete location search with debounced API calls
- **Dynamic Backgrounds** — Gradient backgrounds that change based on weather conditions
- **Smooth Animations** — Entry animations and transitions powered by flutter_animate
- **Pull to Refresh** — Swipe down to refresh weather data
- **Custom App Icon** — Branded SkyPulse launcher icon

## Screenshots

The app features a premium dark theme with glassmorphic cards and dynamic gradients that shift based on current weather conditions (clear, cloudy, rain, snow, thunderstorm).

## Architecture

The project follows a clean, feature-based architecture:

```
lib/
├── main.dart                          # App entry point
├── core/
│   └── constants/
│       ├── api_constants.dart         # Open-Meteo API URLs
│       └── weather_icons.dart         # WMO code → icon/color mapping
└── features/
    └── weather/
        ├── data/
        │   ├── weather_model.dart     # Weather data models
        │   ├── weather_service.dart   # API service layer
        │   └── location_model.dart    # Geocoding search model
        └── presentation/
            ├── weather_screen.dart    # Main screen
            └── widgets/
                ├── current_weather_card.dart
                ├── hourly_forecast_strip.dart
                ├── daily_forecast_list.dart
                ├── weather_detail_grid.dart
                └── search_bar_widget.dart
```

## Tech Stack

- **Framework**: Flutter 3.x with Material 3
- **Language**: Dart 3.x
- **API**: [Open-Meteo](https://open-meteo.com/) (free, no API key required)
- **HTTP**: `http` package
- **Fonts**: Google Fonts (Outfit)
- **Animations**: flutter_animate
- **Loading Effects**: shimmer

## Getting Started

### Prerequisites

- Flutter SDK 3.11+
- Android Studio / VS Code with Flutter extension
- An Android device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nqobile-x/skyPulse-weather.git
   cd skyPulse-weather
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## API

This app uses the [Open-Meteo API](https://open-meteo.com/), which is:
- Completely free for non-commercial use
- No API key required
- Provides current weather, hourly, and daily forecasts
- Includes geocoding search for city lookup

## License

This project is licensed under the MIT License.
