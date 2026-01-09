import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/control_panel.dart';
import '../widgets/stats_card.dart';
import '../widgets/weather_chart.dart';
import '../widgets/weather_table.dart';
import '../widgets/logs_table.dart';
import '../widgets/weather_map.dart';

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
    _tabController = TabController(length: 4, vsync: this);

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ヘッダー
                Row(
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
                const SizedBox(height: 20),

                // メインコンテンツ（2カラムレイアウト）
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左カラム：コントロールパネルと統計サマリー（スクロール可能）
                        SizedBox(
                          width: 350,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // コントロールパネル
                                const ControlPanel(),

                                const SizedBox(height: 16),

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

                                const SizedBox(height: 8),

                                // 統計サマリー
                                const StatsCard(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        // 右カラム：タブバーと地図/表
                        Expanded(
                          child: Column(
                            children: [
                              // タブバー
                              Material(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: const Color(0xFF667EEA),
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: const Color(0xFF667EEA),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  tabs: const [
                                    Tab(icon: Icon(Icons.map), text: '地図'),
                                    Tab(icon: Icon(Icons.bar_chart), text: 'グラフ'),
                                    Tab(icon: Icon(Icons.table_chart), text: 'データ表'),
                                    Tab(icon: Icon(Icons.history), text: '操作ログ'),
                                  ],
                                ),
                              ),
                              // タブビュー
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                  ),
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      WeatherMap(),
                                      WeatherChart(),
                                      WeatherTable(),
                                      LogsTable(onTabSelected: () {
                                        Provider.of<WeatherProvider>(context, listen: false).loadLogs();
                                      }),
                                    ],
                                  ),
                                ),
                              ),
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
