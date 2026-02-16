# SkyPulse Weather ☁️

A modern, beautifully designed weather app built with Flutter. SkyPulse delivers real-time weather data with a premium dark UI, smooth animations, and an intuitive search experience.

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

1.  **Clean Architecture**: Segregating code into `data` (API, models) and `presentation` (UI, widgets) layers to ensure maintainability and testability.
2.  **Modern UI/UX Design**: Moving away from standard Material widgets to create a custom, high-fidelity interface with:
    -   Dynamic **gradient backgrounds** that shift based on weather conditions.
    -   **Glassmorphism** effects for a modern, layered look.
    -   **Smooth animations** using `flutter_animate` to make the app feel alive.
3.  **Robust API Integration**: Implementing complex asynchronous data fetching from Open-Meteo, handling loading states, errors, and data transformation efficiently.
4.  **State Management**: Using `setState` efficiently for this scale, while structuring the app to easily migrate to Riverpod or Bloc for larger iterations.

This app isn't just about fetching data—it's about **delivering a premium user experience** and robust code quality.

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
