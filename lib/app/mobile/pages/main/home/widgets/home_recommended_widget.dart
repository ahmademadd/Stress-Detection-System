import 'package:flutter/material.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/bluetooth_connect_widget.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/stress_heatmap_widget.dart';
import 'package:stress_sense/core/theme/app_text_styles.dart';

import '../../../../../../core/constants/words.dart';
import '../../../../../habit_tracker/view/widgets/habit_tracker_widget.dart';
import '../../../../scaffolds/app_padding_scaffold.dart';
import '../../../../widgets/list_tile_widget.dart';
import '../../../others/test.dart';

class HomeRecommendedWidget extends StatelessWidget {
  const HomeRecommendedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPaddingScaffold(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTileWidget(
          title: Text(
            'Daily stress',
            style: AppTextStyles.xlBold,
          ),
          widgets: [
            Text(
              'Keep track of your child\'s wellbeing',
              style: AppTextStyles.m,
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        const BluetoothConnectWidget(),
        const SizedBox(height: 20.0),
        const StressHeatmap(),
        ElevatedButton(
            onPressed: () async { await insertTestStressData();},
            child: const Text("test data",style: TextStyle(color: Colors.red),)),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
