import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevicePicker extends StatelessWidget {
  final List<ScanResult> devices;
  final Function(BluetoothDevice) onSelected;

  const BluetoothDevicePicker({
    super.key,
    required this.devices,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Select a Device",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: devices.isEmpty
                  ? const Center(child: Text("No devices found"))
                  : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].device;
                  return ListTile(
                    title: Text(
                      device.platformName.isNotEmpty
                          ? device.platformName
                          : "Unknown Device",
                    ),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: const Icon(Icons.bluetooth),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(device);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
