/// Data model representing the full weather response from Open-Meteo.
class WeatherData {
  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.timezone,
  });

  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final String timezone;

  /// Parse the raw Open-Meteo JSON into a [WeatherData] model.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    // Parse hourly data
    final hourlyTimes = (hourlyJson['time'] as List).cast<String>();
    final hourlyTemps = (hourlyJson['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourlyJson['weather_code'] as List).cast<int>();
    final hourlyPrecipProb =
        (hourlyJson['precipitation_probability'] as List).cast<int?>();

    final hourlyList = <HourlyWeather>[];
    for (var i = 0; i < hourlyTimes.length; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: hourlyTemps[i].toDouble(),
        weatherCode: hourlyCodes[i],
        precipitationProbability: hourlyPrecipProb[i] ?? 0,
      ));
    }

    // Parse daily data
    final dailyTimes = (dailyJson['time'] as List).cast<String>();
    final dailyCodes = (dailyJson['weather_code'] as List).cast<int>();
    final dailyMaxTemps = (dailyJson['temperature_2m_max'] as List).cast<num>();
    final dailyMinTemps = (dailyJson['temperature_2m_min'] as List).cast<num>();
    final dailySunrise = (dailyJson['sunrise'] as List).cast<String>();
    final dailySunset = (dailyJson['sunset'] as List).cast<String>();
    final dailyUvMax = (dailyJson['uv_index_max'] as List).cast<num>();
    final dailyPrecipMax =
        (dailyJson['precipitation_probability_max'] as List).cast<int?>();

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
      ));
    }

    return WeatherData(
      timezone: json['timezone'] as String,
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
      ),
      hourly: hourlyList,
      daily: dailyList,
    );
  }
}

/// Current weather conditions.
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
}

/// A single hour's forecast data.
class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
}

/// A single day's forecast data.
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
  });

  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final int precipitationProbabilityMax;
}
