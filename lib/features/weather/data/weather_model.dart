/// Data model representing the full weather response from Open-Meteo.
class WeatherData {
  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.timezone,
    required this.utcOffsetSeconds,
  });

  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final String timezone;
  final int utcOffsetSeconds;

  /// Returns the current moment expressed as a naive datetime in the
  /// location's local timezone, matching how Open-Meteo encodes hourly times.
  DateTime get locationNow {
    final locTime = DateTime.now().toUtc().add(Duration(seconds: utcOffsetSeconds));
    return DateTime(locTime.year, locTime.month, locTime.day, locTime.hour, locTime.minute);
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    // Hourly
    final hourlyTimes = (hourlyJson['time'] as List).cast<String>();
    final hourlyTemps = (hourlyJson['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourlyJson['weather_code'] as List).cast<int>();
    final hourlyPrecipProb =
        (hourlyJson['precipitation_probability'] as List).cast<int?>();
    final hourlyPrecip = (hourlyJson['precipitation'] as List).cast<num?>();
    final hourlyWind = (hourlyJson['wind_speed_10m'] as List).cast<num?>();
    final hourlyVis = (hourlyJson['visibility'] as List).cast<num?>();

    final hourlyList = <HourlyWeather>[];
    for (var i = 0; i < hourlyTimes.length; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: hourlyTemps[i].toDouble(),
        weatherCode: hourlyCodes[i],
        precipitationProbability: hourlyPrecipProb[i] ?? 0,
        precipitation: (hourlyPrecip[i] ?? 0).toDouble(),
        windSpeed: (hourlyWind[i] ?? 0).toDouble(),
        visibility: (hourlyVis[i] ?? 10000).toDouble(),
      ));
    }

    // Daily
    final dailyTimes = (dailyJson['time'] as List).cast<String>();
    final dailyCodes = (dailyJson['weather_code'] as List).cast<int>();
    final dailyMaxTemps =
        (dailyJson['temperature_2m_max'] as List).cast<num>();
    final dailyMinTemps =
        (dailyJson['temperature_2m_min'] as List).cast<num>();
    final dailySunrise = (dailyJson['sunrise'] as List).cast<String>();
    final dailySunset = (dailyJson['sunset'] as List).cast<String>();
    final dailyUvMax = (dailyJson['uv_index_max'] as List).cast<num>();
    final dailyPrecipMax =
        (dailyJson['precipitation_probability_max'] as List).cast<int?>();
    final dailyWindMax =
        (dailyJson['wind_speed_10m_max'] as List).cast<num?>();
    final dailyGustsMax =
        (dailyJson['wind_gusts_10m_max'] as List).cast<num?>();
    final dailyPrecipSum =
        (dailyJson['precipitation_sum'] as List).cast<num?>();
    final dailyRainSum = (dailyJson['rain_sum'] as List).cast<num?>();
    final dailySnowSum = (dailyJson['snowfall_sum'] as List).cast<num?>();

    final dailyList = <DailyWeather>[];
    for (var i = 0; i < dailyTimes.length; i++) {
      dailyList.add(DailyWeather(
        date: DateTime.parse(dailyTimes[i]),
        weatherCode: dailyCodes[i],
        temperatureMax: dailyMaxTemps[i].toDouble(),
        temperatureMin: dailyMinTemps[i].toDouble(),
        sunrise: DateTime.parse(dailySunrise[i]),
        sunset: DateTime.parse(dailySunset[i]),
        uvIndexMax: dailyUvMax[i].toDouble(),
        precipitationProbabilityMax: dailyPrecipMax[i] ?? 0,
        windSpeedMax: (dailyWindMax[i] ?? 0).toDouble(),
        windGustsMax: (dailyGustsMax[i] ?? 0).toDouble(),
        precipitationSum: (dailyPrecipSum[i] ?? 0).toDouble(),
        rainSum: (dailyRainSum[i] ?? 0).toDouble(),
        snowfallSum: (dailySnowSum[i] ?? 0).toDouble(),
      ));
    }

    return WeatherData(
      timezone: json['timezone'] as String,
      utcOffsetSeconds: (json['utc_offset_seconds'] as num).toInt(),
      current: CurrentWeather(
        temperature: (currentJson['temperature_2m'] as num).toDouble(),
        apparentTemperature:
            (currentJson['apparent_temperature'] as num).toDouble(),
        humidity: (currentJson['relative_humidity_2m'] as num).toInt(),
        precipitation: (currentJson['precipitation'] as num).toDouble(),
        weatherCode: currentJson['weather_code'] as int,
        windSpeed: (currentJson['wind_speed_10m'] as num).toDouble(),
        windDirection: (currentJson['wind_direction_10m'] as num).toInt(),
        pressure: (currentJson['surface_pressure'] as num).toDouble(),
        uvIndex: (currentJson['uv_index'] as num).toDouble(),
        cloudCover: (currentJson['cloud_cover'] as num).toInt(),
        visibility: (currentJson['visibility'] as num).toDouble(),
        isDay: (currentJson['is_day'] as int) == 1,
        windGusts: (currentJson['wind_gusts_10m'] as num).toDouble(),
      ),
      hourly: hourlyList,
      daily: dailyList,
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.uvIndex,
    required this.cloudCover,
    required this.visibility,
    required this.isDay,
    required this.windGusts,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double uvIndex;
  final int cloudCover;
  final double visibility; // meters
  final bool isDay;
  final double windGusts;
}

class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.precipitation,
    required this.windSpeed,
    required this.visibility,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final double precipitation; // mm
  final double windSpeed; // km/h
  final double visibility; // meters
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.precipitationProbabilityMax,
    required this.windSpeedMax,
    required this.windGustsMax,
    required this.precipitationSum,
    required this.rainSum,
    required this.snowfallSum,
  });

  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final int precipitationProbabilityMax;
  final double windSpeedMax;
  final double windGustsMax;
  final double precipitationSum; // mm
  final double rainSum; // mm
  final double snowfallSum; // mm
}
