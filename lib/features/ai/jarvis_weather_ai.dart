import 'package:flutter/material.dart';
import '../weather/data/weather_model.dart';
import '../../core/constants/weather_icons.dart';

enum InsightType { alert, summary, activity, clothing, health, week, tip }

class AriaInsight {
  const AriaInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final InsightType type;
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  bool get isAlert => type == InsightType.alert;
}

// Back-compat alias
typedef JarvisInsight = AriaInsight;

/// Rule-based atmospheric intelligence engine.
class AriaWeatherAI {
  AriaWeatherAI._();

  // Back-compat alias
  static List<AriaInsight> analyze(
    WeatherData weather,
    String cityName,
    bool isCelsius,
  ) => _analyze(weather, cityName, isCelsius);

  static List<AriaInsight> _analyze(
    WeatherData weather,
    String cityName,
    bool isCelsius,
  ) {
    final insights = <AriaInsight>[];
    final current = weather.current;
    final daily = weather.daily;
    final hourly = weather.hourly;
    final locationNow = weather.locationNow;

    final alert = _severeAlert(current, daily);
    if (alert != null) insights.add(alert);

    insights.add(_currentSummary(current, cityName, isCelsius));

    final precip = _precipitationForecast(hourly, daily, locationNow);
    if (precip != null) insights.add(precip);

    final uv = _uvAdvice(current, daily);
    if (uv != null) insights.add(uv);

    final wind = _windAdvisory(current);
    if (wind != null) insights.add(wind);

    final visibility = _visibilityAlert(current);
    if (visibility != null) insights.add(visibility);

    insights.add(_clothingAdvice(current, isCelsius));
    insights.add(_activityAdvice(current, daily.isNotEmpty ? daily.first : null));

    final humidity = _humidityComfort(current);
    if (humidity != null) insights.add(humidity);

    if (daily.length >= 4) insights.add(_weekOutlook(daily, isCelsius));

    return insights;
  }

  /// Natural-language briefing ARIA speaks aloud.
  static String generateBriefing(
    WeatherData weather,
    String city,
    bool isCelsius,
  ) {
    final c = weather.current;
    final cond = WeatherIcons.description(c.weatherCode);
    final temp = _tempStr(c.temperature, isCelsius);
    final feels = _tempStr(c.apparentTemperature, isCelsius);
    final hour = weather.locationNow.hour;

    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final windNote = c.windSpeed > 40
        ? 'Strong winds at ${c.windSpeed.round()} kilometres per hour, gusting to ${c.windGusts.round()}. '
        : c.windSpeed > 22
            ? 'Moderate breeze at ${c.windSpeed.round()} kilometres per hour. '
            : '';

    String rainNote = '';
    if (weather.daily.isNotEmpty) {
      final today = weather.daily.first;
      if (today.precipitationProbabilityMax > 60) {
        rainNote = '${today.precipitationProbabilityMax} percent chance of rain today — carry an umbrella. ';
      } else if (today.precipitationProbabilityMax > 30) {
        rainNote =
            'Slight chance of rain at ${today.precipitationProbabilityMax} percent. ';
      }
    }

    final uvNote = c.isDay && c.uvIndex >= 5
        ? 'UV index is ${c.uvIndex.toStringAsFixed(0)}, ${c.uvIndex >= 8 ? "very high — limit sun exposure and apply SPF 50" : "moderate — light sun protection recommended for outdoor time"}. '
        : '';

    final visNote = c.visibility < 2000
        ? 'Visibility is reduced to ${(c.visibility / 1000).toStringAsFixed(1)} kilometres — drive carefully. '
        : '';

    String weekNote = '';
    if (weather.daily.length >= 4) {
      final rainDays =
          weather.daily.where((d) => d.precipitationProbabilityMax > 50).length;
      if (rainDays == 0) {
        final peak = weather.daily
            .map((d) => d.temperatureMax)
            .reduce((a, b) => a > b ? a : b);
        weekNote =
            'The week ahead looks dry, peaking at ${_tempStr(peak, isCelsius)}. ';
      } else if (rainDays <= 2) {
        weekNote =
            '$rainDays rainy day${rainDays > 1 ? "s" : ""} expected this week. ';
      } else {
        weekNote = 'A wet week ahead with $rainDays days of rain expected. ';
      }
    }

    return '$greeting. I am ARIA, your atmospheric intelligence. '
        'Current conditions in $city: $cond. '
        'Temperature is $temp, feeling like $feels with ${c.humidity} percent humidity. '
        '$windNote$rainNote$uvNote$visNote${weekNote}Stay safe and have a great day.';
  }

  // ── Severe weather alert ──────────────────────────────────────────────────

  static AriaInsight? _severeAlert(
    CurrentWeather c,
    List<DailyWeather> daily,
  ) {
    final code = c.weatherCode;

    if (code >= 95) {
      return const JarvisInsight(
        type: InsightType.alert,
        title: 'Thunderstorm Alert',
        message:
            'Dangerous thunderstorm conditions. Stay indoors, away from windows and open spaces. Avoid tall structures.',
        icon: Icons.flash_on_rounded,
        color: Color(0xFFFFAB40),
      );
    }
    if (code == 75 || code == 86) {
      return const JarvisInsight(
        type: InsightType.alert,
        title: 'Heavy Snow Warning',
        message:
            'Heavy snowfall in progress. Roads may be hazardous. Allow extra travel time and drive with caution.',
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF80DEEA),
      );
    }
    if (code == 65 || code == 82) {
      return const JarvisInsight(
        type: InsightType.alert,
        title: 'Heavy Rain Alert',
        message:
            'Heavy rainfall may cause localized flooding. Avoid waterways and low-lying areas.',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF0288D1),
      );
    }
    if (c.uvIndex >= 11) {
      return JarvisInsight(
        type: InsightType.alert,
        title: 'Extreme UV — ${c.uvIndex.toStringAsFixed(0)}',
        message:
            'UV radiation is at extreme levels. Avoid direct sun exposure between 10AM–4PM. Apply SPF 50+ every 2 hours.',
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFFF5252),
      );
    }
    if (c.windGusts >= 90) {
      return JarvisInsight(
        type: InsightType.alert,
        title: 'Dangerous Wind Gusts',
        message:
            'Wind gusts of ${c.windGusts.round()} km/h detected. Secure all loose outdoor items. Avoid high-profile vehicles.',
        icon: Icons.wind_power_rounded,
        color: const Color(0xFFFF7043),
      );
    }

    // Check upcoming severe in next 3 days
    for (final day in daily.take(3)) {
      if (day.weatherCode >= 95) {
        return const JarvisInsight(
          type: InsightType.alert,
          title: 'Thunderstorm in Forecast',
          message:
              'Severe thunderstorm conditions expected within 3 days. Monitor updates and plan outdoor activities carefully.',
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFFFD54F),
        );
      }
    }

    return null;
  }

  // ── Current conditions summary ────────────────────────────────────────────

  static JarvisInsight _currentSummary(
    CurrentWeather c,
    String city,
    bool isCelsius,
  ) {
    final temp = _tempStr(c.temperature, isCelsius);
    final feels = _tempStr(c.apparentTemperature, isCelsius);
    final condition = WeatherIcons.description(c.weatherCode);
    final period = c.isDay ? 'daytime' : 'nighttime';

    final diff = c.apparentTemperature - c.temperature;
    String comfort = '';
    if (diff <= -3) comfort = ' Wind chill makes it feel noticeably colder.';
    if (diff >= 3) comfort = ' High humidity adds to the perceived heat.';

    final cloudStr = c.cloudCover > 70
        ? ' Sky is ${c.cloudCover}% cloud-covered.'
        : c.cloudCover < 20
            ? ' Sky is mostly clear.'
            : '';

    return JarvisInsight(
      type: InsightType.summary,
      title: 'Live Conditions — $city',
      message:
          '$condition in $city during $period hours. Currently $temp, feeling like $feels.$comfort$cloudStr',
      icon: WeatherIcons.icon(c.weatherCode),
      color: WeatherIcons.color(c.weatherCode),
    );
  }

  // ── Precipitation ─────────────────────────────────────────────────────────

  static JarvisInsight? _precipitationForecast(
    List<HourlyWeather> hourly,
    List<DailyWeather> daily,
    DateTime locationNow,
  ) {
    final next6h = hourly
        .where((h) =>
            h.time.isAfter(locationNow) &&
            h.time.isBefore(locationNow.add(const Duration(hours: 6))))
        .toList();

    final rainHour =
        next6h.where((h) => h.precipitationProbability > 50).toList();
    if (rainHour.isNotEmpty) {
      final h = rainHour.first;
      final hrs = h.time.difference(locationNow).inHours;
      final timeStr =
          hrs == 0 ? 'within the hour' : 'in about $hrs hour${hrs == 1 ? "" : "s"}';
      return JarvisInsight(
        type: InsightType.tip,
        title: 'Rain Likely Soon',
        message:
            '${h.precipitationProbability}% chance of precipitation $timeStr. Carry an umbrella before heading out.',
        icon: Icons.umbrella_rounded,
        color: const Color(0xFF4FC3F7),
      );
    }

    if (daily.length >= 3) {
      final dryCount = daily.where((d) => d.precipitationProbabilityMax < 20).length;
      if (dryCount == daily.length) {
        return const JarvisInsight(
          type: InsightType.tip,
          title: 'Dry Week Ahead',
          message:
              'No significant rain expected over the next 7 days. Excellent conditions for planning outdoor events.',
          icon: Icons.wb_sunny_outlined,
          color: Color(0xFFFFD54F),
        );
      }

      final wettest = daily.reduce(
          (a, b) => a.precipitationProbabilityMax > b.precipitationProbabilityMax ? a : b);
      if (wettest.precipitationProbabilityMax > 70) {
        final dayName = _dayLabel(wettest.date);
        return JarvisInsight(
          type: InsightType.tip,
          title: 'Heaviest Rain — $dayName',
          message:
              '${wettest.precipitationProbabilityMax}% rain probability ${dayName.toLowerCase()} with up to ${wettest.precipitationSum.toStringAsFixed(1)} mm expected. Plan indoor alternatives.',
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF29B6F6),
        );
      }
    }

    return null;
  }

  // ── UV advice ─────────────────────────────────────────────────────────────

  static JarvisInsight? _uvAdvice(
    CurrentWeather c,
    List<DailyWeather> daily,
  ) {
    if (!c.isDay) return null;
    final peak = daily.isNotEmpty ? daily.first.uvIndexMax : c.uvIndex;
    if (peak < 3) return null;

    if (peak >= 8) {
      return JarvisInsight(
        type: InsightType.health,
        title: 'UV Index ${peak.toStringAsFixed(1)} — Very High',
        message:
            'Peak UV is very high today. Apply SPF 30+ sunscreen, wear sunglasses and a wide-brim hat. Limit direct sun 10AM–4PM.',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFFFF7043),
      );
    }
    return JarvisInsight(
      type: InsightType.health,
      title: 'UV Index ${peak.toStringAsFixed(1)} — Moderate',
      message:
          'UV levels are moderate today. Apply SPF 15+ for outdoor activities lasting more than 30 minutes.',
      icon: Icons.wb_sunny_outlined,
      color: const Color(0xFFFFD54F),
    );
  }

  // ── Wind advisory ─────────────────────────────────────────────────────────

  static JarvisInsight? _windAdvisory(CurrentWeather c) {
    if (c.windGusts >= 60 || c.windSpeed >= 45) {
      return JarvisInsight(
        type: InsightType.tip,
        title: 'Strong Winds — ${c.windSpeed.round()} km/h',
        message:
            'Gusting to ${c.windGusts.round()} km/h. Secure outdoor furniture, be cautious near large trees, and avoid open exposed areas.',
        icon: Icons.air_rounded,
        color: const Color(0xFF90CAF9),
      );
    }
    return null;
  }

  // ── Visibility ────────────────────────────────────────────────────────────

  static JarvisInsight? _visibilityAlert(CurrentWeather c) {
    final vis = c.visibility / 1000; // km
    if (vis <= 1.0) {
      return JarvisInsight(
        type: InsightType.alert,
        title: 'Very Low Visibility',
        message:
            'Visibility is only ${vis.toStringAsFixed(1)} km due to fog or haze. Drive with headlights on and maintain extra following distance.',
        icon: Icons.foggy,
        color: const Color(0xFFB0BEC5),
      );
    }
    if (vis <= 4.0) {
      return JarvisInsight(
        type: InsightType.tip,
        title: 'Reduced Visibility',
        message:
            'Visibility reduced to ${vis.toStringAsFixed(1)} km. Exercise extra caution when driving.',
        icon: Icons.foggy,
        color: const Color(0xFF90A4AE),
      );
    }
    return null;
  }

  // ── Clothing ──────────────────────────────────────────────────────────────

  static JarvisInsight _clothingAdvice(CurrentWeather c, bool isCelsius) {
    final t = c.apparentTemperature;
    final isRainy = c.weatherCode >= 51 && c.weatherCode <= 82;

    String advice;
    IconData icon;
    Color color;

    if (t < 0) {
      advice = 'Dress in thermal base layers + heavy winter coat. Gloves, hat, and scarf essential.';
      icon = Icons.ac_unit_rounded;
      color = const Color(0xFF80DEEA);
    } else if (t < 8) {
      advice = 'Heavy coat or parka with warm underlayers. Gloves and hat recommended.';
      icon = Icons.ac_unit_rounded;
      color = const Color(0xFF4FC3F7);
    } else if (t < 15) {
      advice = 'Jacket or thick sweater. A scarf or light gloves may be comfortable.';
      icon = Icons.dry_cleaning_rounded;
      color = const Color(0xFF90CAF9);
    } else if (t < 20) {
      advice = 'Light jacket or long-sleeve top. Layering works well for changing conditions.';
      icon = Icons.dry_cleaning_rounded;
      color = const Color(0xFF81C784);
    } else if (t < 28) {
      advice = 'Light summer clothing — T-shirt, shorts, or a summer dress is comfortable.';
      icon = Icons.wb_sunny_outlined;
      color = const Color(0xFFFFD54F);
    } else {
      advice =
          'Very light, breathable fabrics. Stay hydrated and seek shade during peak hours.';
      icon = Icons.thermostat_rounded;
      color = const Color(0xFFFF8A65);
    }

    if (isRainy) advice += ' Bring a waterproof layer or umbrella.';

    return JarvisInsight(
      type: InsightType.clothing,
      title: 'What to Wear Today',
      message: 'Feels like ${_tempStr(t, isCelsius)} — $advice',
      icon: icon,
      color: color,
    );
  }

  // ── Activity ──────────────────────────────────────────────────────────────

  static JarvisInsight _activityAdvice(
    CurrentWeather c,
    DailyWeather? today,
  ) {
    final code = c.weatherCode;
    final t = c.apparentTemperature;

    String msg;
    IconData icon;
    Color color;

    if (code >= 95) {
      msg = 'Stay indoors. Thunderstorm conditions are dangerous for any outdoor activity.';
      icon = Icons.home_rounded;
      color = const Color(0xFFFFAB40);
    } else if (code >= 80 || (code >= 61 && code <= 67)) {
      msg = 'Best to stay in or carry an umbrella. Great day for a café, museum, or movie.';
      icon = Icons.local_cafe_rounded;
      color = const Color(0xFF4FC3F7);
    } else if (code >= 71 && code <= 77) {
      msg = 'Snowy! Perfect for skiing, snowboarding, or a scenic winter walk — dress warmly.';
      icon = Icons.sledding_rounded;
      color = const Color(0xFFE0E0E0);
    } else if (code == 45 || code == 48) {
      msg = 'Foggy conditions. Drive carefully and allow extra time for all journeys.';
      icon = Icons.directions_car_rounded;
      color = const Color(0xFFB0BEC5);
    } else if (t > 36) {
      msg =
          'Extreme heat. Limit outdoor exertion, stay in air-conditioned spaces, and drink water every 30 min.';
      icon = Icons.thermostat_rounded;
      color = const Color(0xFFFF5252);
    } else if (t > 28 && c.humidity > 70) {
      msg =
          'Hot and humid. Outdoor exercise is possible — take frequent breaks and hydrate generously.';
      icon = Icons.fitness_center_rounded;
      color = const Color(0xFFFFD54F);
    } else if (code <= 1 && t >= 15 && t <= 30) {
      msg =
          'Outstanding conditions! Ideal for cycling, hiking, outdoor sports, or a picnic in the park.';
      icon = Icons.directions_bike_rounded;
      color = const Color(0xFF81C784);
    } else if (code <= 3 && t >= 10) {
      msg = 'Pleasant conditions. A walk, jog, or light outdoor activity would be refreshing.';
      icon = Icons.directions_walk_rounded;
      color = const Color(0xFF90CAF9);
    } else {
      msg = 'Moderate conditions. Dress appropriately and enjoy light outdoor activities.';
      icon = Icons.emoji_nature_rounded;
      color = const Color(0xFF90CAF9);
    }

    return JarvisInsight(
      type: InsightType.activity,
      title: 'Activity Forecast',
      message: msg,
      icon: icon,
      color: color,
    );
  }

  // ── Humidity ──────────────────────────────────────────────────────────────

  static JarvisInsight? _humidityComfort(CurrentWeather c) {
    if (c.humidity > 80 && c.temperature > 25) {
      return JarvisInsight(
        type: InsightType.health,
        title: 'High Humidity — ${c.humidity}%',
        message:
            'Combining ${c.temperature.round()}° heat with ${c.humidity}% humidity creates sticky, uncomfortable conditions. Sweat evaporation is reduced — hydrate frequently.',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF26C6DA),
      );
    }
    if (c.humidity < 25) {
      return JarvisInsight(
        type: InsightType.health,
        title: 'Very Dry Air — ${c.humidity}%',
        message:
            'Very low humidity can cause dry skin, irritated eyes, and respiratory discomfort. Use moisturizer and drink extra water.',
        icon: Icons.water_drop_outlined,
        color: const Color(0xFFFFD54F),
      );
    }
    return null;
  }

  // ── 7-day outlook ─────────────────────────────────────────────────────────

  static JarvisInsight _weekOutlook(List<DailyWeather> daily, bool isCelsius) {
    final avgTemps = daily
        .map((d) => (d.temperatureMax + d.temperatureMin) / 2)
        .toList();
    final diff = avgTemps.last - avgTemps.first;

    String trend;
    if (diff > 4) {
      trend = 'Warming trend — temperatures rise ~${diff.round()}° by week\'s end.';
    } else if (diff < -4) {
      trend = 'Cooling trend — temperatures drop ~${(-diff).round()}° by week\'s end.';
    } else {
      trend = 'Temperatures remain stable throughout the week.';
    }

    final peakMax = daily.map((d) => d.temperatureMax).reduce((a, b) => a > b ? a : b);
    final rainDays = daily.where((d) => d.precipitationProbabilityMax > 40).length;

    // Find best day by score
    DailyWeather bestDay = daily.first;
    double bestScore = -999;
    for (final d in daily) {
      final score = _score(d);
      if (score > bestScore) {
        bestScore = score;
        bestDay = d;
      }
    }

    final rainStr = rainDays == 0
        ? ' No rain expected.'
        : rainDays == 1
            ? ' 1 rainy day forecast.'
            : ' $rainDays rainy days ahead.';

    final bestStr = ' Best day: ${_dayLabel(bestDay.date)} '
        '(${_tempStr(bestDay.temperatureMax, isCelsius)}/${_tempStr(bestDay.temperatureMin, isCelsius)}).';

    return JarvisInsight(
      type: InsightType.week,
      title: '7-Day Outlook',
      message:
          '$trend Peak: ${_tempStr(peakMax, isCelsius)}.$rainStr$bestStr',
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFFCE93D8),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _score(DailyWeather d) {
    double s = 0;
    if (d.weatherCode <= 1) {
      s += 40;
    } else if (d.weatherCode <= 3) {
      s += 28;
    } else if (d.weatherCode <= 55) {
      s += 10;
    }

    final avg = (d.temperatureMax + d.temperatureMin) / 2;
    if (avg >= 18 && avg <= 25) {
      s += 30;
    } else if (avg >= 13 && avg <= 30) {
      s += 18;
    } else if (avg >= 8 && avg <= 34) {
      s += 8;
    }

    s -= d.precipitationProbabilityMax * 0.25;
    s -= (d.windGustsMax * 0.08).clamp(0, 15);
    return s;
  }

  static String _tempStr(double celsius, bool isCelsius) {
    if (isCelsius) return '${celsius.round()}°C';
    final f = celsius * 9 / 5 + 32;
    return '${f.round()}°F';
  }

  static String _dayLabel(DateTime date) {
    final today = DateTime.now();
    final diff =
        DateTime(date.year, date.month, date.day)
            .difference(DateTime(today.year, today.month, today.day))
            .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(date.weekday - 1) % 7];
  }
}
