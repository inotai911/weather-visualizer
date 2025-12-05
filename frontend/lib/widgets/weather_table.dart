import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';

class WeatherTable extends StatelessWidget {
  const WeatherTable({super.key});

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
              Row(
                children: [
                  const Icon(Icons.table_chart, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    '気象データ一覧',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.weatherData.length}件',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const Divider(),
              
              // テーブル
              Expanded(
                child: provider.weatherData.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.table_rows, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('データがありません', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFF667EEA)),
                            headingTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 50,
                            columns: const [
                              DataColumn(label: Text('日時')),
                              DataColumn(label: Text('地域')),
                              DataColumn(label: Text('天気')),
                              DataColumn(label: Text('気温(℃)'), numeric: true),
                              DataColumn(label: Text('湿度(%)'), numeric: true),
                              DataColumn(label: Text('降水量(mm)'), numeric: true),
                              DataColumn(label: Text('風速(m/s)'), numeric: true),
                              DataColumn(label: Text('気圧(hPa)'), numeric: true),
                            ],
                            rows: provider.weatherData.map((data) {
                              final dateFormat = DateFormat('MM/dd HH:mm');
                              return DataRow(
                                cells: [
                                  DataCell(Text(dateFormat.format(data.timestamp))),
                                  DataCell(Text(data.locationName)),
                                  DataCell(Text(data.weatherEmoji, style: const TextStyle(fontSize: 20))),
                                  DataCell(Text(data.temperature?.toStringAsFixed(1) ?? '-')),
                                  DataCell(Text(data.humidity?.toStringAsFixed(0) ?? '-')),
                                  DataCell(Text(data.precipitation?.toStringAsFixed(1) ?? '-')),
                                  DataCell(Text(data.windSpeed?.toStringAsFixed(1) ?? '-')),
                                  DataCell(Text(data.pressure?.toStringAsFixed(0) ?? '-')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
