import 'package:flutter/material.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/date_range_header.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/timespan_selector_widget.dart';

import '../../../core/timespan/timespan.dart';

class StressOverviewHeader extends StatefulWidget {
  const StressOverviewHeader({super.key});

  @override
  State<StressOverviewHeader> createState() => _StressOverviewHeaderState();
}

class _StressOverviewHeaderState extends State<StressOverviewHeader> {
  TimeSpan _selected = TimeSpan.week;

  @override
  Widget build(BuildContext context) {
    final range = calculateRange(_selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TimeSpanSelector(
          selected: _selected,
          onChanged: (span) {
            setState(() => _selected = span);
            // 🔥 trigger data reload here
          },
        ),

        const SizedBox(height: 12),

        DateRangeHeader(range: range),
      ],
    );
  }

  DateTimeRange calculateRange(TimeSpan span) {
    final now = DateTime.now();

    switch (span) {

      case TimeSpan.week:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );

      case TimeSpan.month:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 27)),
          end: now,
        );

      case TimeSpan.year:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: now,
        );
    }
  }

}
