import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.weatherData.isEmpty) {
          return const SizedBox.shrink();
        }

        final stats = provider.stats;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const Icon(Icons.analytics, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    '統計サマリー',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatItem(
                    icon: Icons.thermostat,
                    label: '平均気温',
                    value: stats.avgTemp != null ? '${stats.avgTemp!.toStringAsFixed(1)}℃' : '-',
                    color: Colors.orange,
                  ),
                  _buildStatItem(
                    icon: Icons.arrow_upward,
                    label: '最高気温',
                    value: stats.maxTemp != null ? '${stats.maxTemp!.toStringAsFixed(1)}℃' : '-',
                    color: Colors.red,
                  ),
                  _buildStatItem(
                    icon: Icons.arrow_downward,
                    label: '最低気温',
                    value: stats.minTemp != null ? '${stats.minTemp!.toStringAsFixed(1)}℃' : '-',
                    color: Colors.blue,
                  ),
                  _buildStatItem(
                    icon: Icons.water_drop,
                    label: '平均湿度',
                    value: stats.avgHumidity != null ? '${stats.avgHumidity!.toStringAsFixed(0)}%' : '-',
                    color: Colors.cyan,
                  ),
                  _buildStatItem(
                    icon: Icons.umbrella,
                    label: '総降水量',
                    value: stats.totalPrecipitation != null ? '${stats.totalPrecipitation!.toStringAsFixed(1)}mm' : '-',
                    color: Colors.indigo,
                  ),
                  _buildStatItem(
                    icon: Icons.air,
                    label: '平均風速',
                    value: stats.avgWindSpeed != null ? '${stats.avgWindSpeed!.toStringAsFixed(1)}m/s' : '-',
                    color: Colors.teal,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
