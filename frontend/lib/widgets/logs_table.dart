import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';

class LogsTable extends StatefulWidget {
  final VoidCallback? onTabSelected;
  
  const LogsTable({super.key, this.onTabSelected});

  @override
  State<LogsTable> createState() => _LogsTableState();
}

class _LogsTableState extends State<LogsTable> {
  @override
  void initState() {
    super.initState();
    // タブが選択されたらログを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabSelected?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: EdgeInsets.zero,
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
                  const Icon(Icons.history, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    '操作ログ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.loadLogs(),
                    tooltip: '更新',
                  ),
                ],
              ),
              const Divider(),
              
              // ログテーブル
              Expanded(
                child: provider.logs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('ログがありません', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFF667EEA)),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('操作種別')),
                            DataColumn(label: Text('詳細')),
                            DataColumn(label: Text('日時')),
                          ],
                          rows: provider.logs.map((log) {
                            final dateFormat = DateFormat('yyyy/MM/dd HH:mm:ss');
                            return DataRow(
                              cells: [
                                DataCell(Text(log.id.toString())),
                                DataCell(_buildActionTypeBadge(log.actionType)),
                                DataCell(Text(log.actionDetail ?? '-')),
                                DataCell(Text(dateFormat.format(log.timestamp))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTypeBadge(String actionType) {
    Color color;
    IconData icon;
    
    switch (actionType) {
      case 'API_FETCH':
        color = Colors.green;
        icon = Icons.download;
        break;
      case 'API_CALL':
        color = Colors.blue;
        icon = Icons.api;
        break;
      case 'PAGE_VIEW':
        color = Colors.purple;
        icon = Icons.visibility;
        break;
      case 'DATA_VIEW':
        color = Colors.orange;
        icon = Icons.table_chart;
        break;
      case 'CHART_VIEW':
        color = Colors.cyan;
        icon = Icons.bar_chart;
        break;
      case 'LOCATION_ADD':
        color = Colors.teal;
        icon = Icons.add_location;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            actionType,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
