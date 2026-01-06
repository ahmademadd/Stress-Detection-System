import 'package:flutter/material.dart';

class DateRangeHeader extends StatelessWidget {
  final DateTimeRange range;

  const DateRangeHeader({super.key, required this.range});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.chevron_left, color: Colors.white54),
        const SizedBox(width: 8),
        Text(
          _formatRange(range),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.white54),
      ],
    );
  }

  String _formatRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;

    if (start.month == end.month) {
      return '${_month(start)} ${start.day}–${end.day}';
    }

    return '${_month(start)} ${start.day} – ${_month(end)} ${end.day}';
  }

  String _month(DateTime date) {
    return const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][date.month - 1];
  }
}
