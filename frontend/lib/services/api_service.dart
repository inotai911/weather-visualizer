import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// API通信サービス
class ApiService {
  // バックエンドのベースURL（環境に応じて変更）
  static const String baseUrl = 'http://localhost:5000';

  /// 地域一覧を取得
  Future<List<Location>> getLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/api/locations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Location.fromJson(json)).toList();
    }
    throw Exception('地域の取得に失敗しました');
  }

  /// 気象データを取得
  Future<List<WeatherData>> getWeatherData({
    String? location,
    String? startDate,
    String? endDate,
    int limit = 168,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
    };
    if (location != null && location.isNotEmpty) {
      params['location'] = location;
    }
    if (startDate != null) {
      params['start_date'] = startDate;
    }
    if (endDate != null) {
      params['end_date'] = '$endDate 23:59:59';
    }

    final uri = Uri.parse('$baseUrl/api/weather').replace(queryParameters: params);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => WeatherData.fromJson(json)).toList();
    }
    throw Exception('気象データの取得に失敗しました');
  }

  /// APIから気象データを取得してDBに保存
  Future<bool> fetchWeatherFromApi(String locationName, {int days = 7}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/weather/fetch'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'location_name': locationName,
        'days': days,
      }),
    );
    return response.statusCode == 200;
  }

  /// 全地域のデータを取得
  Future<Map<String, dynamic>> fetchAllWeather() async {
    final response = await http.post(Uri.parse('$baseUrl/api/weather/fetch_all'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('全地域のデータ取得に失敗しました');
  }

  /// グラフ用データを取得
  Future<Map<String, dynamic>> getChartData({
    required String location,
    required String type,
    int hours = 72,
  }) async {
    final params = {
      'location': location,
      'type': type,
      'hours': hours.toString(),
    };
    
    final uri = Uri.parse('$baseUrl/api/weather/chart_data').replace(queryParameters: params);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('グラフデータの取得に失敗しました');
  }

  /// 操作ログを取得
  Future<List<UserLog>> getLogs({int limit = 100}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/logs?limit=$limit'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => UserLog.fromJson(json)).toList();
    }
    throw Exception('ログの取得に失敗しました');
  }
}
