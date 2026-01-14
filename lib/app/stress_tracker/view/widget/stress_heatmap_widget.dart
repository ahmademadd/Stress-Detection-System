import 'package:cristalyse/cristalyse.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/timespan_selector_widget.dart';

import '../../../../core/timespan/timespan.dart';
import '../../repo/daily_stress_summary_repository.dart';
import '../../repo/firestore_stress_summary_repository.dart';
import '../chart_data.dart';

class StressHeatmap extends StatefulWidget {
  const StressHeatmap({super.key});

  @override
  State<StressHeatmap> createState() => _StressHeatmapState();
}

class _StressHeatmapState extends State<StressHeatmap> {
  final StressSummaryRepository stressSummaryRepository = FirestoreStressSummaryRepository();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  TimeSpan _selectedTimeSpan = TimeSpan.week;
  DateTime get endDate => DateTime.now();
  late DateTime startDate;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startDate = calculateRange(_selectedTimeSpan);
  }

  Widget _buildBarChartWidget(DateTime startDate, DateTime endDate) {
    return StreamBuilder<Map<String, int>>(
      stream: stressSummaryRepository.watchDailyStressCounts(
        startDate: startDate,
        endDate: endDate,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final barChartData = snapshot.data!.entries.map((entry) {
          final date = DateTime.parse(entry.key);
          return {
            'day': weekdayLabel(date),
            'count': entry.value,
          };
        }).toList();

        if (barChartData.isEmpty) {
          return const Center(child: Text('No stress data yet'));
        }

        return CristalyseChart()
          .data(barChartData)
          .mapping(
            x: 'day',
            y: 'count',
          )
          .geomBar(
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFF81C784),
          )
          .theme(ChartTheme.darkTheme())
          .animate(duration: Duration(milliseconds: 800))
          .build();
      },
    );
  }

  List<Map<String, dynamic>> buildHeatmapData(Map<String, int> stressCounts) {
    if (stressCounts.isEmpty) return [];

    final dates = stressCounts.keys.map((d) => DateTime.parse(d)).toList()
      ..sort();

    final startDate = dates.first;
    final List<Map<String, dynamic>> result = [];

    stressCounts.forEach((dayKey, count) {
      final date = DateTime.parse(dayKey);

      result.add({
        'day': weekdayLabel(date),
        'week': 'W${weekIndex(date, startDate)}',
        'count': count,
      });
    });

    return result;
  }

  String weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

  Widget _buildLineChartWidget(DateTime startDate, DateTime endDate) {
    return StreamBuilder<Map<String, int>>(
      stream: stressSummaryRepository.watchDailyStressCounts(
        startDate: startDate,
        endDate: endDate,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: Text('No data')),
          );
        }

        final chartData = mapToChartData(snapshot.data!);

        return SizedBox(
          height: 180,
          child: LineChart(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                /// 👇 DATES HERE
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _dateInterval(chartData.dates.length),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.dates.length) {
                        return const SizedBox.shrink();
                      }

                      final date = chartData.dates[index];

                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${date.month}/${date.day}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: chartData.spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  barWidth: 2,
                  color: Colors.white,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _dateInterval(int length) {
    if (length <= 7) return 1;     // 1d / 7d
    if (length <= 31) return 5;    // 4w
    return 30;                     // 1y
  }



  Widget _buildHeatmapWidget(DateTime startDate, DateTime endDate) {
    return StreamBuilder<Map<String, int>>(
      stream: stressSummaryRepository.watchDailyStressCounts(
        startDate: startDate,
        endDate: endDate,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final heatmapData = buildHeatmapData(snapshot.data!);

        if (heatmapData.isEmpty) {
          return const Center(child: Text('No stress data yet'));
        }

        return CristalyseChart()
          .data(heatmapData)
          .mappingHeatMap(
            x: 'week',
            y: 'day',
            value: 'count',
          )
          .geomHeatMap(
            cellSpacing: 2,
            cellBorderRadius: BorderRadius.circular(4),
            colorGradient: const [
              Color(0xFFE8F5E9),
              Color(0xFF81C784),
              Color(0xFF1B5E20),
            ],
            interpolateColors: true,
            showValues: false,
          )
          .animate(duration: Duration(milliseconds: 500))
          .theme(ChartTheme.darkTheme())
          .build();
      },
    );
  }

  int weekIndex(DateTime date, DateTime start) {
    return date.difference(start).inDays ~/ 7;
  }

  Widget _buildPageIndicator(int pageCount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isActive = index == _currentPage;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 12 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.greenAccent : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  DateTime calculateRange(TimeSpan span) {
    final now = DateTime.now();

    switch (span) {
      case TimeSpan.day:
        return DateTime(now.year, now.month, now.day);

      case TimeSpan.week:
        return now.subtract(const Duration(days: 6));

      case TimeSpan.month:
        return DateTime(now.year, now.month - 1, now.day);

      case TimeSpan.year:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Column(
            children: [
              TimeSpanSelector(
                selected: _selectedTimeSpan,
                onChanged: (span) {
                  setState(() {
                    _selectedTimeSpan = span;
                    startDate = calculateRange(_selectedTimeSpan);
                  });
                }
              ),
              //_buildLineChartWidget(startDate, endDate),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildLineChartWidget(startDate, endDate),
                    _buildBarChartWidget(
                      startDate,
                      endDate,
                    ),
                    _buildHeatmapWidget(startDate, endDate),
                  ],
                ),
              )
            ],
          ),
        ),
        _buildPageIndicator(3),
      ],
    );
  }
}
