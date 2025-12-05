/// 気象データモデル
class WeatherData {
  final int id;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? temperature;
  final double? humidity;
  final double? precipitation;
  final double? windSpeed;
  final int? windDirection;
  final int? weatherCode;
  final double? pressure;

  WeatherData({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.temperature,
    this.humidity,
    this.precipitation,
    this.windSpeed,
    this.windDirection,
    this.weatherCode,
    this.pressure,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      id: json['id'] ?? 0,
      locationName: json['location_name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      precipitation: json['precipitation']?.toDouble(),
      windSpeed: json['wind_speed']?.toDouble(),
      windDirection: json['wind_direction'],
      weatherCode: json['weather_code'],
      pressure: json['pressure']?.toDouble(),
    );
  }

  String get weatherEmoji {
    if (weatherCode == null) return '❓';
    if (weatherCode == 0) return '☀️';
    if (weatherCode! <= 3) return '⛅';
    if (weatherCode! <= 49) return '🌫️';
    if (weatherCode! <= 59) return '🌧️';
    if (weatherCode! <= 69) return '🌨️';
    if (weatherCode! <= 79) return '❄️';
    if (weatherCode! <= 84) return '🌧️';
    if (weatherCode! <= 94) return '⛈️';
    return '🌪️';
  }
}

/// 地域モデル
class Location {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

/// ユーザー操作ログモデル
class UserLog {
  final int id;
  final String actionType;
  final String? actionDetail;
  final DateTime timestamp;

  UserLog({
    required this.id,
    required this.actionType,
    this.actionDetail,
    required this.timestamp,
  });

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      id: json['id'] ?? 0,
      actionType: json['action_type'] ?? '',
      actionDetail: json['action_detail'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// 統計サマリーモデル
class WeatherStats {
  final double? avgTemp;
  final double? maxTemp;
  final double? minTemp;
  final double? avgHumidity;
  final double? totalPrecipitation;
  final double? avgWindSpeed;

  WeatherStats({
    this.avgTemp,
    this.maxTemp,
    this.minTemp,
    this.avgHumidity,
    this.totalPrecipitation,
    this.avgWindSpeed,
  });

  factory WeatherStats.fromWeatherData(List<WeatherData> data) {
    if (data.isEmpty) {
      return WeatherStats();
    }

    final temps = data.where((d) => d.temperature != null).map((d) => d.temperature!).toList();
    final humidities = data.where((d) => d.humidity != null).map((d) => d.humidity!).toList();
    final precips = data.where((d) => d.precipitation != null).map((d) => d.precipitation!).toList();
    final winds = data.where((d) => d.windSpeed != null).map((d) => d.windSpeed!).toList();

    return WeatherStats(
      avgTemp: temps.isNotEmpty ? temps.reduce((a, b) => a + b) / temps.length : null,
      maxTemp: temps.isNotEmpty ? temps.reduce((a, b) => a > b ? a : b) : null,
      minTemp: temps.isNotEmpty ? temps.reduce((a, b) => a < b ? a : b) : null,
      avgHumidity: humidities.isNotEmpty ? humidities.reduce((a, b) => a + b) / humidities.length : null,
      totalPrecipitation: precips.isNotEmpty ? precips.reduce((a, b) => a + b) : null,
      avgWindSpeed: winds.isNotEmpty ? winds.reduce((a, b) => a + b) / winds.length : null,
    );
  }
}
