import 'package:fl_chart/fl_chart.dart';

class ChartData {
  final List<FlSpot> spots;
  final List<DateTime> dates;

  ChartData(this.spots, this.dates);
}

ChartData mapToChartData(Map<String, int> data) {
  final entries = data.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final spots = <FlSpot>[];
  final dates = <DateTime>[];

  for (int i = 0; i < entries.length; i++) {
    final date = DateTime.parse(entries[i].key);
    final value = entries[i].value.toDouble();

    dates.add(date);
    spots.add(FlSpot(i.toDouble(), value));
  }

  return ChartData(spots, dates);
}
