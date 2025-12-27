import 'package:flutter/material.dart';
import 'package:stress_sense/core/notifiers/notifiers.dart';
import '../../../../core/bluetooth/device_connection_state.dart';
import '../../../../core/constants/words.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../mobile/widgets/button_widget.dart';
import '../../services/bluetooth_service.dart';
import '../../services/permission_service.dart';
import 'bluetooth_device_picker.dart';

class BluetoothConnectWidget extends StatefulWidget {
  const BluetoothConnectWidget({super.key});

  @override
  State<BluetoothConnectWidget> createState() => _BluetoothConnectWidgetState();
}

class _BluetoothConnectWidgetState extends State<BluetoothConnectWidget> {
  final BluetoothService bluetoothService = BluetoothService();

  String get buttonText {
    switch (AppData.blueToothConnectionState.value) {
      case DeviceConnectionState.scanning:
        return "Scanning...";
      case DeviceConnectionState.connecting:
        return "Connecting...";
      case DeviceConnectionState.connected:
        return "Connected ✓";
      default:
        return "Connect Wearable";
    }
  }

  Color get buttonColor {
    if (AppData.blueToothConnectionState.value == DeviceConnectionState.connected) return Colors.green;
    if (AppData.blueToothConnectionState.value == DeviceConnectionState.scanning ||
        AppData.blueToothConnectionState.value == DeviceConnectionState.connecting) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  Future<void> _connectFlow() async {
    final granted = await PermissionService.requestBlePermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bluetooth permissions required")),
      );
      return;
    }

    try {
      final devices = await bluetoothService.scanDevices();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) =>
            BluetoothDevicePicker(
              devices: devices,
              onSelected: (device) async {
                await bluetoothService.connectToWearable(device);
              },
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _disconnect() async {
    if (!mounted) return;
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Disconnect Wearable'),
            content: const Text(
              'Are you sure you want to disconnect?',
              style: AppTextStyles.m,
            ),
            actions: [
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // close dialog FIRST
                  await bluetoothService.disconnect();
                },
                child: const Text('Disconnect'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // cancel dialog
                },
                child: const Text(Words.cancel),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void popPage() {
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppData.blueToothConnectionState,
      builder: (context, value, child) {
        return ButtonWidget(
          isFilled: true,
          callback: AppData.blueToothConnectionState.value == DeviceConnectionState.connected
              ? _disconnect
              : _connectFlow,
          label:
            buttonText,
        );
      }
    );
  }
}
