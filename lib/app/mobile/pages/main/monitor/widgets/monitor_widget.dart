import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/pages/main/monitor/widgets/heart_rate_card.dart';
import 'package:stress_sense/app/mobile/scaffolds/app_padding_scaffold.dart';
import 'package:stress_sense/app/stress_tracker/view/widget/stress_status_banner_widget.dart';

import '../../../../../../core/bluetooth/device_connection_state.dart';
import '../../../../../../core/notifiers/notifiers.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../stress_tracker/view/widget/bluetooth_connect_widget.dart';
import '../../../../widgets/list_tile_widget.dart';

class MonitorWidget extends StatelessWidget {
  const MonitorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPaddingScaffold(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const BluetoothConnectWidget(),
        const SizedBox(height: 30),
        const HeartRateCard(),
        const SizedBox(height: 30),
        const StressStatusBannerWidget(),
        const SizedBox(height: 30),
        ListTileWidget(
          title: Container(
            padding: const EdgeInsets.only(left: 10, bottom: 3),
            child: const Text(
              'About',
              style: AppTextStyles.m,
            ),
          ),
          widgets: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFF313b36),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Text(
                'This app monitors your stress levels using '
                'physiological data from your ESP32 wearable. '
                'The data will then be processed through an AI model developed by Empactica.',
                style: AppTextStyles.s,
              ),
            ),
          ],
        ),
        ElevatedButton(
            onPressed: () {
              AppData.isStressed.value = true;
              AppData.blueToothConnectionState.value = DeviceConnectionState.connected;
              Future.delayed(const Duration(seconds: 5), () {
                AppData.isStressed.value = false;
                AppData.blueToothConnectionState.value = DeviceConnectionState.disconnected;
              });
            },
            child: const Text(
              "test banner",
              style: TextStyle(color: Colors.green),
            )
        ),
        ElevatedButton(
            onPressed: () async {
              AppData.blueToothConnectionState.value = DeviceConnectionState.connected;
              for (int i = 0; i < 200; i++) {
                AppData.bpm.value = Random().nextInt(120) + 60;
                await Future.delayed(Duration(milliseconds: 10000));
              }
              AppData.blueToothConnectionState.value = DeviceConnectionState.disconnected;
              AppData.bpm.value = null;

            },
            child: const Text(
              "test bpm",
              style: TextStyle(color: Colors.green),
            )
        ),
        ElevatedButton(
            onPressed: () {
              AppData.blueToothConnectionState.value = DeviceConnectionState.disconnected;
              AppData.bpm.value = null;
            },
            child: const Text(
              "stop bpm",
              style: TextStyle(color: Colors.green),
            )
        ),
      ],
    );
  }
}
