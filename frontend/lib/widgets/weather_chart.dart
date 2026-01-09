import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherChart extends StatelessWidget {
  const WeatherChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // チャートタイプ選択
              Row(
                children: [
                  const Icon(Icons.bar_chart, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    '気象グラフ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildChartTypeDropdown(context, provider),
                ],
              ),
              const Divider(),
              
              // グラフエリア
              Expanded(
                child: provider.weatherData.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('データがありません', style: TextStyle(color: Colors.grey)),
                            Text('「API取得」ボタンでデータを取得してください', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    : _buildChart(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartTypeDropdown(BuildContext context, WeatherProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.chartType,
          items: const [
            DropdownMenuItem(value: 'temperature', child: Text('🌡️ 気温')),
            DropdownMenuItem(value: 'humidity', child: Text('💧 湿度')),
            DropdownMenuItem(value: 'precipitation', child: Text('🌧️ 降水量')),
            DropdownMenuItem(value: 'wind_speed', child: Text('💨 風速')),
            DropdownMenuItem(value: 'pressure', child: Text('🔘 気圧')),
          ],
          onChanged: (value) {
            if (value != null) provider.setChartType(value);
          },
        ),
      ),
    );
  }

  Widget _buildChart(WeatherProvider provider) {
    final data = _prepareChartData(provider.weatherData, provider.chartType);
    
    if (data.isEmpty) {
      return const Center(
        child: Text('このデータタイプのデータがありません'),
      );
    }

    final chartInfo = _getChartInfo(provider.chartType);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: chartInfo.interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (data.length / 6).ceil().toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    final date = data[index].timestamp;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          '${date.month}/${date.day}\n${date.hour}:00',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: chartInfo.interval,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(chartInfo.decimals)}${chartInfo.unit}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          minY: chartInfo.minY,
          maxY: chartInfo.maxY,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.value);
              }).toList(),
              isCurved: true,
              color: chartInfo.color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: chartInfo.color.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < data.length) {
                    final item = data[index];
                    return LineTooltipItem(
                      '${item.timestamp.month}/${item.timestamp.day} ${item.timestamp.hour}:00\n${item.value.toStringAsFixed(1)}${chartInfo.unit}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<_ChartDataPoint> _prepareChartData(List<WeatherData> weatherData, String chartType) {
    final sortedData = [...weatherData]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedData
        .where((d) => _getValue(d, chartType) != null)
        .map((d) => _ChartDataPoint(
              timestamp: d.timestamp,
              value: _getValue(d, chartType)!,
            ))
        .toList();
  }

  double? _getValue(WeatherData data, String chartType) {
    switch (chartType) {
      case 'temperature':
        return data.temperature;
      case 'humidity':
        return data.humidity;
      case 'precipitation':
        return data.precipitation;
      case 'wind_speed':
        return data.windSpeed;
      case 'pressure':
        return data.pressure;
      default:
        return data.temperature;
    }
  }

  _ChartInfo _getChartInfo(String chartType) {
    switch (chartType) {
      case 'temperature':
        return _ChartInfo(
          color: Colors.red,
          unit: '℃',
          minY: -10,
          maxY: 40,
          interval: 10,
          decimals: 0,
        );
      case 'humidity':
        return _ChartInfo(
          color: Colors.blue,
          unit: '%',
          minY: 0,
          maxY: 100,
          interval: 20,
          decimals: 0,
        );
      case 'precipitation':
        return _ChartInfo(
          color: Colors.cyan,
          unit: 'mm',
          minY: 0,
          maxY: 20,
          interval: 5,
          decimals: 1,
        );
      case 'wind_speed':
        return _ChartInfo(
          color: Colors.orange,
          unit: 'm/s',
          minY: 0,
          maxY: 30,
          interval: 5,
          decimals: 0,
        );
      case 'pressure':
        return _ChartInfo(
          color: Colors.purple,
          unit: 'hPa',
          minY: 980,
          maxY: 1040,
          interval: 10,
          decimals: 0,
        );
      default:
        return _ChartInfo(
          color: Colors.red,
          unit: '',
          minY: 0,
          maxY: 100,
          interval: 20,
          decimals: 0,
        );
    }
  }
}

class _ChartDataPoint {
  final DateTime timestamp;
  final double value;

  _ChartDataPoint({required this.timestamp, required this.value});
}

class _ChartInfo {
  final Color color;
  final String unit;
  final double minY;
  final double maxY;
  final double interval;
  final int decimals;

  _ChartInfo({
    required this.color,
    required this.unit,
    required this.minY,
    required this.maxY,
    required this.interval,
    required this.decimals,
  });
}
