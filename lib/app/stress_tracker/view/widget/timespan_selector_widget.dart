import 'package:flutter/material.dart';

import '../../../../core/timespan/timespan.dart';

class TimeSpanSelector extends StatelessWidget {
  final TimeSpan selected;
  final ValueChanged<TimeSpan> onChanged;

  const TimeSpanSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TimeSpan.values.map((span) {
          final isSelected = span == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(span),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade800 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _label(span),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(TimeSpan span) {
    switch (span) {
      case TimeSpan.day:
        return '1d';
      case TimeSpan.week:
        return '7d';
      case TimeSpan.month:
        return '4w';
      case TimeSpan.year:
        return '1y';
    }
  }
}
