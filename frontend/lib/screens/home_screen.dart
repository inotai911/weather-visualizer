import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/control_panel.dart';
import '../widgets/stats_card.dart';
import '../widgets/weather_chart.dart';
import '../widgets/weather_table.dart';
import '../widgets/logs_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 初期データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      provider.loadLocations();
      provider.loadWeatherData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      '気象情報可視化システム',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // メインコンテンツ
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // コントロールパネル
                      const ControlPanel(),
                      
                      // ステータスメッセージ
                      Consumer<WeatherProvider>(
                        builder: (context, provider, child) {
                          if (provider.successMessage != null) {
                            return _buildStatusMessage(provider.successMessage!, false);
                          }
                          if (provider.errorMessage != null) {
                            return _buildStatusMessage(provider.errorMessage!, true);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // 統計カード
                      const StatsCard(),
                      
                      // タブバー
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xFF667EEA),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xFF667EEA),
                          tabs: const [
                            Tab(icon: Icon(Icons.bar_chart), text: 'グラフ'),
                            Tab(icon: Icon(Icons.table_chart), text: 'データ表'),
                            Tab(icon: Icon(Icons.history), text: '操作ログ'),
                          ],
                        ),
                      ),
                      
                      // タブビュー
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            const WeatherChart(),
                            const WeatherTable(),
                            LogsTable(onTabSelected: () {
                              Provider.of<WeatherProvider>(context, listen: false).loadLogs();
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String message, bool isError) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red[800] : Colors.green[800],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              Provider.of<WeatherProvider>(context, listen: false).clearMessages();
            },
          ),
        ],
      ),
    );
  }
}
