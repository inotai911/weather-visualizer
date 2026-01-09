import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherMap extends StatefulWidget {
  const WeatherMap({super.key});

  @override
  State<WeatherMap> createState() => _WeatherMapState();
}

class _WeatherMapState extends State<WeatherMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        // デフォルトは日本の中心座標
        LatLng center = const LatLng(36.5, 138.0);
        double zoom = 5.2;

        // データがある場合は、そのデータの中心とズームを計算
        if (provider.weatherData.isNotEmpty) {
          // すべてのデータポイントから中心を計算
          double avgLat = provider.weatherData.map((d) => d.latitude).reduce((a, b) => a + b) / provider.weatherData.length;
          double avgLon = provider.weatherData.map((d) => d.longitude).reduce((a, b) => a + b) / provider.weatherData.length;
          center = LatLng(avgLat, avgLon);
          
          // データポイント数に応じてズームレベルを調整
          if (provider.weatherData.length < 5) {
            // 少数の地点：大阪から東京が見えるくらいの広域表示
            zoom = 7.5;
          } else if (provider.weatherData.length < 20) {
            // 中程度の地点数：地域全体が見える
            zoom = 8.5;
          } else {
            // 多数の地点：詳細表示
            zoom = 9.5;
          }

          // マップコントローラーで中心を移動
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(center, zoom);
          });
        }

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: zoom,
                  minZoom: 4.0,
                  maxZoom: 18.0,
                ),
                children: [
                  // タイルレイヤー（地図画像）
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.weather_visualizer',
                    maxZoom: 19,
                  ),
                  // 天気マーカーレイヤー
                  MarkerLayer(
                    markers: _buildWeatherMarkers(provider.weatherData),
                  ),
                ],
              ),
              // 凡例
              Positioned(
                top: 16,
                right: 16,
                child: _buildLegend(),
              ),
              // データなしの場合のメッセージ
              if (provider.weatherData.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          '地図にデータがありません',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '「データ取得」ボタンで天気データを読み込んでください',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ),
        );
      },
    );
  }

  List<Marker> _buildWeatherMarkers(List<WeatherData> weatherData) {
    return weatherData.map((data) {
      return Marker(
        point: LatLng(data.latitude, data.longitude),
        width: 120,
        height: 100,
        child: GestureDetector(
          onTap: () => _showWeatherDetail(data),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 天気アイコンと気温
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTemperatureColor(data.temperature),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.weatherEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    if (data.temperature != null)
                      Text(
                        '${data.temperature!.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // 地点名
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  data.locationName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getTemperatureColor(double? temperature) {
    if (temperature == null) return Colors.grey;
    if (temperature >= 30) return Colors.red.shade600;
    if (temperature >= 25) return Colors.orange.shade600;
    if (temperature >= 20) return Colors.amber.shade600;
    if (temperature >= 15) return Colors.lightGreen.shade600;
    if (temperature >= 10) return Colors.lightBlue.shade600;
    if (temperature >= 5) return Colors.blue.shade600;
    return Colors.indigo.shade600;
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '気温凡例',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.red.shade600, '30°C以上'),
          _buildLegendItem(Colors.orange.shade600, '25-30°C'),
          _buildLegendItem(Colors.amber.shade600, '20-25°C'),
          _buildLegendItem(Colors.lightGreen.shade600, '15-20°C'),
          _buildLegendItem(Colors.lightBlue.shade600, '10-15°C'),
          _buildLegendItem(Colors.blue.shade600, '5-10°C'),
          _buildLegendItem(Colors.indigo.shade600, '5°C未満'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showWeatherDetail(WeatherData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(data.weatherEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.locationName,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('気温', data.temperature, '°C'),
              _buildDetailRow('湿度', data.humidity, '%'),
              _buildDetailRow('降水量', data.precipitation, 'mm'),
              _buildDetailRow('風速', data.windSpeed, 'm/s'),
              if (data.windDirection != null)
                _buildDetailRow('風向', data.windDirection!.toDouble(), '°'),
              _buildDetailRow('気圧', data.pressure, 'hPa'),
              const Divider(),
              Text(
                '座標: ${data.latitude.toStringAsFixed(4)}, ${data.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double? value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value != null ? '${value.toStringAsFixed(1)} $unit' : '---',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
