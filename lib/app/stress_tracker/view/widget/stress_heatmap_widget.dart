import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../repo/daily_stress_summary_repository.dart';
import '../../repo/firestore_stress_summary_repository.dart';

class StressHeatmap extends StatefulWidget {
  const StressHeatmap({super.key});

  @override
  State<StressHeatmap> createState() => _StressHeatmapState();
}

class _StressHeatmapState extends State<StressHeatmap> {
  final StressSummaryRepository stressSummaryRepository =
      FirestoreStressSummaryRepository(
    firestore: FirebaseFirestore.instance,
    userId: FirebaseAuth.instance.currentUser!.uid,
  );
  final PageController _pageController = PageController();
  late final List<Widget> _pages;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final DateTime endDate = DateTime.now();
    final DateTime startDate = DateTime(endDate.year, endDate.month, 1);

    _pages = [
      _buildBarChartWidget(endDate.subtract(Duration(days: 6)), endDate),
      _buildHeatmapWidget(startDate, endDate),
      //_buildThirdWidget(),
    ];
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView(
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            controller: _pageController,
            children: _pages,
          ),
        ),
        _buildPageIndicator(_pages.length),
      ],
    );
  }
}
