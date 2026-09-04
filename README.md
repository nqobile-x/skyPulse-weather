# SkyPulse Weather ☁️

A modern, beautifully designed weather app built with Flutter. SkyPulse delivers real-time weather data with a premium dark UI, GPU-rendered animated weather scenes, and ARIA — an AI weather assistant that speaks your forecast.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![API](https://img.shields.io/badge/API-Open--Meteo-orange)

## 📱 Screenshots

| Current Weather | Hourly Forecast | 7-Day Outlook |
|:---:|:---:|:---:|
| ![Current Weather](screenshots/home_screen.png) | ![Hourly Forecast](screenshots/hourly_view.png) | ![7-Day Outlook](screenshots/daily_view.png) |
*(Add your screenshots here: `screenshots/home_screen.png`, etc.)*
![WhatsApp Image 2026-02-16 at 16 45 06](https://github.com/user-attachments/assets/d4dd8d14-a35e-4c6e-8c6d-6ce24f0b4cf9)
![WhatsApp Image 2026-02-16 at 16 45 05](https://github.com/user-attachments/assets/d8fd0377-750d-4081-9094-a882b5e79a64)


https://github.com/user-attachments/assets/72a732df-cd83-4a93-b5d0-e3fc5384e908


## 🚀 Why I Built This

I built SkyPulse to demonstrate my ability to create **production-ready Flutter applications** that go beyond basic functionality. This project serves as a showcase of:

1.  **Clean Architecture**: Segregating code into `data` (API, models), `presentation` (UI, widgets), and `core` (services, constants) layers for maintainability and testability.
2.  **Custom GPU Rendering**: Building animated weather scenes entirely with `CustomPainter` — no external asset files. Rain, snow, lightning, sun rays, and stars are all drawn at runtime using static particle arrays allocated once at class load time, eliminating heap churn during `paint()`.
3.  **AI-Powered Voice Assistant (ARIA)**: A rule-based AI engine that analyses live weather data and generates natural-language briefings spoken aloud via TTS — greeting by time of day, condition summary, wind/rain/UV/visibility alerts, and a week outlook.
4.  **Performance-First Design**: `RepaintBoundary` isolates the animated scene layer from the scroll tree. A single `AnimationController` is synced to `vsync`. `ValueNotifier<bool>` drives the waveform animation reactively without triggering parent rebuilds. A `_fetchVersion` counter discards stale API responses from rapid city switching.
5.  **Modern UI/UX**: Hero layout with 88px ultra-thin temperature display (Apple Weather style), condition-keyed dark backgrounds, and smooth entry animations via `flutter_animate`.

This app isn't just about fetching data — it's about **delivering a premium user experience** backed by robust, optimised code.

## Features

- **ARIA AI Assistant** — Rule-based weather AI that generates spoken briefings with time-of-day greetings, condition summaries, wind/rain/UV/visibility alerts, and a week outlook
- **Animated Weather Scenes** — GPU-rendered scenes for sun, night, cloud, rain, snow, fog, and storm; drawn with `CustomPainter`, zero external assets
- **Real-Time Weather** — Current temperature, feels-like, humidity, wind speed, UV index, visibility, and more
- **24-Hour Forecast** — Horizontally scrollable hourly forecast strip with local timezone times
- **7-Day Forecast** — Daily forecast with high/low temperatures and condition icons
- **Atmospheric Details** — Wind, humidity, UV index, pressure, visibility, sunrise/sunset
- **City Search** — Autocomplete location search with debounced API calls; each city uses its own lat/lon for accurate local data
- **Timezone-Aware** — All times displayed in the searched city's local timezone, not the device's
- **C°/F° Toggle** — Unit preference persisted across sessions via shared preferences
- **Pull to Refresh** — Swipe down to refresh weather data
- **Custom App Icon** — Branded SkyPulse launcher icon

## Architecture

The project follows a clean, feature-based architecture:

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # Open-Meteo API URLs
│   │   └── weather_icons.dart         # WMO code → icon/color/description mapping
│   └── services/
│       └── aria_voice.dart            # TTS service with ValueNotifier<bool> speaking state
└── features/
    ├── ai/
    │   └── jarvis_weather_ai.dart     # AriaWeatherAI — analyze() + generateBriefing()
    └── weather/
        ├── data/
        │   ├── weather_model.dart     # Weather data models
        │   ├── weather_service.dart   # Open-Meteo API + geocoding service
        │   └── location_model.dart    # Geocoding search model
        └── presentation/
            ├── weather_screen.dart    # Main screen — hero layout, ARIA integration
            └── widgets/
                ├── weather_scene.dart         # CustomPainter animated weather scenes
                ├── aria_panel.dart            # ARIA panel — insights, briefing, waveform, speak button
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
- **Fonts**: Google Fonts
- **Animations**: `flutter_animate` + custom `AnimationController` + `CustomPainter`
- **Text-to-Speech**: `flutter_tts` (Android system TTS — no cloud dependency)
- **Persistence**: `shared_preferences`

## Getting Started

### Prerequisites

- Flutter SDK 3.11+
- Android Studio / VS Code with Flutter extension
- An Android device or emulator (API 21+)

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
- Returns timezone data so local times are always accurate per city

## License

This project is licensed under the MIT License.
