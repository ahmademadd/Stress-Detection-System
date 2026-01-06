import 'package:flutter/material.dart';
import 'package:stress_sense/core/bluetooth/device_connection_state.dart';

import '../../../../core/notifiers/notifiers.dart';

class StressStatusBannerWidget extends StatefulWidget {
  const StressStatusBannerWidget({super.key});

  @override
  State<StressStatusBannerWidget> createState() => _StressStatusBannerWidgetState();
}

class _StressStatusBannerWidgetState extends State<StressStatusBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeviceConnectionState>(
      valueListenable: AppData.blueToothConnectionState,
      builder: (context, connectionState, _) {
        final connected =
            connectionState == DeviceConnectionState.connected;

        if (connected && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!connected && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.value = 0;
        }

        return ValueListenableBuilder<bool>(
          valueListenable: AppData.isStressed,
          builder: (context, stressed, _) {
            return _buildStatusCard(
              connected: connectionState == DeviceConnectionState.connected,
              stressed: stressed,
            );
          },
        );
      },
    );
  }

  Widget _buildStatusCard({
    required bool connected,
    required bool stressed,
  }) {
    Color color;
    IconData icon;
    String title;
    String subtitle;

    if (!connected) {
      color = Color(0xFF313b36);
      icon = Icons.bluetooth_disabled;
      title = "Unknown state";
      subtitle = "Not connected";
    } else if (stressed) {
      color = Colors.red.shade600;
      icon = Icons.sentiment_very_dissatisfied;
      title = "Stressed";
      subtitle = "High stress detected";
    } else {
      color = Colors.greenAccent;
      icon = Icons.self_improvement;
      title = "Calm";
      subtitle = "Stress levels are normal";
    }

    return ScaleTransition(
      scale: connected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: AnimatedContainer(
        width: 290,
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: connected? color : null, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      //color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
