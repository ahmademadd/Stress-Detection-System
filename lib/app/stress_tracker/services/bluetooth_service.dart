import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:stress_sense/app/stress_tracker/services/stress_api_service.dart';

import '../../../core/bluetooth/device_connection_state.dart';
import '../../../core/errors/bluetooth_exception.dart';
import '../../../core/notifiers/notifiers.dart';

class BluetoothService {
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  final List<ScanResult> scanResults = [];

  /// Change this to your ESP32 BLE service UUID
  final Guid serviceUUID = Guid("12345678-1234-1234-1234-123456789abc");
  final Guid characteristicUUID =
  Guid("abcd1234-5678-1234-5678-abcdef123456");

  final StressApiService stressService = StressApiService();
  // ===== Sliding windows =====
  final List<double> accX = [];
  final List<double> accY = [];
  final List<double> accZ = [];
  final List<double> bvp  = [];
  final List<double> eda  = [];
  final List<double> temp = [];

// Window sizes (match backend frequencies)
  static const int ACC_WINDOW  = 64;
  static const int BVP_WINDOW  = 128;
  static const int EDA_WINDOW  = 32;
  static const int TEMP_WINDOW = 32;

  Future<List<ScanResult>> scanDevices() async {
    try {
      scanResults.clear();
      AppData.blueToothConnectionState.value =
          DeviceConnectionState.scanning;

      final isOn = await ensureBluetoothIsOn();
      if (!isOn) {
        throw BluetoothException("Bluetooth is turned off");
      }

      final subscription =
      FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          if (!scanResults.any(
                  (e) => e.device.remoteId == r.device.remoteId)) {
            scanResults.add(r);
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
      );

      await Future.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();
      await subscription.cancel();

      return scanResults;
    } catch (e) {
      throw BluetoothException(
          "Failed to scan devices: ${e.toString()}");
    } finally {
      AppData.blueToothConnectionState.value =
          DeviceConnectionState.disconnected;
    }
  }

  Future<bool> ensureBluetoothIsOn() async {
    final state = await FlutterBluePlus.adapterState.first;

    if (state != BluetoothAdapterState.on) {
      // On Android, this opens system dialog
      await FlutterBluePlus.turnOn();

      // Wait until user turns Bluetooth ON
      final newState = await FlutterBluePlus.adapterState
          .firstWhere((s) => s == BluetoothAdapterState.on);

      return newState == BluetoothAdapterState.on;
    }

    return true;
  }

  Future<void> connectToWearable(
      BluetoothDevice selectedDevice) async {
    try {
      device = selectedDevice;
      AppData.blueToothConnectionState.value =
          DeviceConnectionState.connecting;

      await device!.connect(
        timeout: const Duration(seconds: 10),
      );

      await _discoverServices();

      AppData.blueToothConnectionState.value =
          DeviceConnectionState.connected;
    } catch (e) {
      AppData.blueToothConnectionState.value =
          DeviceConnectionState.disconnected;
      throw BluetoothException(
          "Failed to connect to device ${e.toString()}");
    }
  }

  Future<void> _discoverServices() async {
    try {
      final services = await device!.discoverServices();

      for (var s in services) {
        if (s.uuid == serviceUUID) {
          for (var c in s.characteristics) {
            if (c.uuid == characteristicUUID) {
              characteristic = c;
              await characteristic!.setNotifyValue(true);
              characteristic!.lastValueStream.listen(_onDataReceived);
              return;
            }
          }
        }
      }
      throw BluetoothException(
          "Required BLE service not found");
    } catch (e) {
      throw BluetoothException(
          "Service discovery failed ${e.toString()}");
    }
  }

  void _onDataReceived(List<int> data) async {
    try {
      final jsonString = utf8.decode(data);
      final Map<String, dynamic> sample = jsonDecode(jsonString);

      // ===== Add sample to buffers =====
      accX.add((sample['acc_x'] as num).toDouble());
      accY.add((sample['acc_y'] as num).toDouble());
      accZ.add((sample['acc_z'] as num).toDouble());
      bvp.add((sample['bvp'] as num).toDouble());
      eda.add((sample['eda'] as num).toDouble());
      temp.add((sample['temp'] as num).toDouble());

      // ===== Keep window size =====
      if (accX.length > ACC_WINDOW) accX.removeAt(0);
      if (accY.length > ACC_WINDOW) accY.removeAt(0);
      if (accZ.length > ACC_WINDOW) accZ.removeAt(0);
      if (bvp.length  > BVP_WINDOW) bvp.removeAt(0);
      if (eda.length  > EDA_WINDOW) eda.removeAt(0);
      if (temp.length > TEMP_WINDOW) temp.removeAt(0);

      // ===== Trigger prediction when window is ready =====
      if (!AppData.isPredictingStress.value &&
          accX.length == ACC_WINDOW &&
          bvp.length == BVP_WINDOW &&
          eda.length == EDA_WINDOW &&
          temp.length == TEMP_WINDOW) {

        AppData.isPredictingStress.value = true;

        await stressService.stressPredictionPipeline(
          accX: List.from(accX),
          accY: List.from(accY),
          accZ: List.from(accZ),
          bvp: List.from(bvp),
          eda: List.from(eda),
          temp: List.from(temp),
        );

        AppData.isPredictingStress.value = false;
      }
    } catch (e) {
      throw BluetoothException(
          "BLE parsing / pipeline error: ${e.toString()}");
    }
  }

  Future<void> disconnect() async {
    try {
      await characteristic?.setNotifyValue(false);
      await device?.disconnect();
    } catch (e) {
      throw BluetoothException("Failed to disconnect device ${e.toString()}");
    } finally {
      device = null;
      characteristic = null;
      AppData.blueToothConnectionState.value =
          DeviceConnectionState.disconnected;
    }
  }
}
