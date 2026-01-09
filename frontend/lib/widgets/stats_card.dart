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
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Color(0xFF667EEA), size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    '統計サマリー',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatItem(
                icon: Icons.thermostat,
                label: '平均気温',
                value: stats.avgTemp != null ? '${stats.avgTemp!.toStringAsFixed(1)}℃' : '-',
                color: Colors.orange,
              ),
              const SizedBox(height: 6),
              _buildStatItem(
                icon: Icons.arrow_upward,
                label: '最高気温',
                value: stats.maxTemp != null ? '${stats.maxTemp!.toStringAsFixed(1)}℃' : '-',
                color: Colors.red,
              ),
              const SizedBox(height: 6),
              _buildStatItem(
                icon: Icons.arrow_downward,
                label: '最低気温',
                value: stats.minTemp != null ? '${stats.minTemp!.toStringAsFixed(1)}℃' : '-',
                color: Colors.blue,
              ),
              const SizedBox(height: 6),
              _buildStatItem(
                icon: Icons.water_drop,
                label: '平均湿度',
                value: stats.avgHumidity != null ? '${stats.avgHumidity!.toStringAsFixed(0)}%' : '-',
                color: Colors.cyan,
              ),
              const SizedBox(height: 6),
              _buildStatItem(
                icon: Icons.umbrella,
                label: '総降水量',
                value: stats.totalPrecipitation != null ? '${stats.totalPrecipitation!.toStringAsFixed(1)}mm' : '-',
                color: Colors.indigo,
              ),
              const SizedBox(height: 6),
              _buildStatItem(
                icon: Icons.air,
                label: '平均風速',
                value: stats.avgWindSpeed != null ? '${stats.avgWindSpeed!.toStringAsFixed(1)}m/s' : '-',
                color: Colors.teal,
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
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
