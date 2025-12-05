import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

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
                  const Icon(Icons.location_on, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    'データ取得・フィルター',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // 地域選択
                  _buildDropdown(
                    label: '地域選択',
                    value: provider.selectedLocation,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('全地域')),
                      ...provider.locations.map((loc) => DropdownMenuItem(
                        value: loc.name,
                        child: Text(loc.name),
                      )),
                    ],
                    onChanged: (value) => provider.setSelectedLocation(value),
                  ),
                  
                  // 開始日
                  _buildDatePicker(
                    context: context,
                    label: '開始日',
                    date: provider.startDate,
                    onChanged: (date) => provider.setStartDate(date),
                  ),
                  
                  // 終了日
                  _buildDatePicker(
                    context: context,
                    label: '終了日',
                    date: provider.endDate,
                    onChanged: (date) => provider.setEndDate(date),
                  ),
                  
                  // 表示時間数
                  _buildDropdown<int>(
                    label: '表示時間数',
                    value: provider.hoursLimit,
                    items: const [
                      DropdownMenuItem(value: 24, child: Text('24時間')),
                      DropdownMenuItem(value: 48, child: Text('48時間')),
                      DropdownMenuItem(value: 72, child: Text('72時間')),
                      DropdownMenuItem(value: 168, child: Text('7日間')),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.setHoursLimit(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: provider.isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('API取得'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: provider.isLoading ? null : () => provider.fetchWeatherFromApi(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('全地域取得'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: provider.isLoading ? null : () => provider.fetchAllWeather(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('データ表示'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: provider.isLoading ? null : () => provider.loadWeatherData(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime date,
    required void Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
