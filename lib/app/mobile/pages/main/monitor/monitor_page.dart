import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/pages/main/monitor/widgets/monitor_widget.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/bluetooth_connect_widget.dart';

import '../../../scaffolds/app_bar_scaffold.dart';

class MonitorPage extends StatelessWidget {
  const MonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      title: 'Stress Monitor',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonitorWidget(),
        ],
      ),
    );
  }
}
