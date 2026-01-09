import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';

/// 気象データの状態管理
class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Location> _locations = [];
  List<WeatherData> _weatherData = [];
  List<UserLog> _logs = [];
  WeatherStats _stats = WeatherStats();
  
  String? _selectedLocation;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  int _hoursLimit = 72;
  String _chartType = 'temperature';
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<Location> get locations => _locations;
  List<WeatherData> get weatherData => _weatherData;
  List<UserLog> get logs => _logs;
  WeatherStats get stats => _stats;
  String? get selectedLocation => _selectedLocation;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get hoursLimit => _hoursLimit;
  String get chartType => _chartType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Setters
  void setSelectedLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void setHoursLimit(int hours) {
    _hoursLimit = hours;
    notifyListeners();
  }

  void setChartType(String type) {
    _chartType = type;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// 地域一覧を取得
  Future<void> loadLocations() async {
    try {
      _locations = await _apiService.getLocations();
      notifyListeners();
    } catch (e) {
      _errorMessage = '地域の取得に失敗しました';
      notifyListeners();
    }
  }

  /// 気象データを取得
  Future<void> loadWeatherData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weatherData = await _apiService.getWeatherData(
        location: _selectedLocation,
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        limit: _hoursLimit,
      );
      _stats = WeatherStats.fromWeatherData(_weatherData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '気象データの取得に失敗しました';
      notifyListeners();
    }
  }

  /// APIから気象データを取得してDBに保存
  Future<void> fetchWeatherFromApi() async {
    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      _errorMessage = '地域を選択してください';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // hoursLimitを日数に変換（24で割って切り上げ）
      final days = (_hoursLimit / 24).ceil();
      final success = await _apiService.fetchWeatherFromApi(_selectedLocation!, days: days);
      _isLoading = false;
      if (success) {
        _successMessage = '${_selectedLocation}の気象データを取得しました';
        await loadWeatherData();
      } else {
        _errorMessage = 'データ取得に失敗しました';
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'データ取得に失敗しました';
      notifyListeners();
    }
  }

  /// 全地域のデータを取得
  Future<void> fetchAllWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.fetchAllWeather();
      _isLoading = false;
      final results = result['results'] as List;
      final successCount = results.where((r) => r['success'] == true).length;
      _successMessage = '$successCount/${results.length} 地域のデータを取得しました';
      await loadWeatherData();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '全地域のデータ取得に失敗しました';
      notifyListeners();
    }
  }

  /// 操作ログを取得
  Future<void> loadLogs() async {
    try {
      _logs = await _apiService.getLogs();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'ログの取得に失敗しました';
      notifyListeners();
    }
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
