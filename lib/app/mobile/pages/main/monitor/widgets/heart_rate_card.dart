import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/bluetooth/device_connection_state.dart';
import '../../../../../../core/notifiers/notifiers.dart';

class HeartRateCard extends StatefulWidget {
  const HeartRateCard({super.key});

  @override
  State<HeartRateCard> createState() => _HeartRateCardState();
}
class _HeartRateCardState extends State<HeartRateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beatController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _beatController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeviceConnectionState>(
      valueListenable: AppData.blueToothConnectionState,
      builder: (context, connectionState, _) {
        final connected =
            connectionState == DeviceConnectionState.connected;

        return ValueListenableBuilder<bool>(
          valueListenable: AppData.isStressed,
          builder: (context, isStressed, _) {
            return ValueListenableBuilder<int?>(
              valueListenable: AppData.bpm,
              builder: (context, bpm, _) {
                _updateHeartbeat(
                  connected: connected,
                  bpm: bpm,
                  isStressed: isStressed,
                );

                return _buildCard(
                  connected: connected,
                  bpm: bpm,
                );
              },
            );
          },
        );
      },
    );
  }

  void _updateHeartbeat({
    required bool connected,
    required int? bpm,
    required bool isStressed,
  }) {
    if (!connected || bpm == null || bpm <= 0) {
      _beatController.stop();
      _beatController.value = 0;
      return;
    }

    final clampedBpm = bpm.clamp(50, 140);
    final baseDuration = (60000 / clampedBpm).round();

    final durationMs = isStressed
        ? (baseDuration * 0.75).round()
        : baseDuration;

    final targetScale = isStressed ? 1.28 : 1.12;

    if (_beatController.duration?.inMilliseconds != durationMs) {
      _beatController.duration = Duration(milliseconds: durationMs);
    }

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: targetScale,
    ).animate(
      CurvedAnimation(
        parent: _beatController,
        curve: Curves.easeInOut,
      ),
    );

    if (!_beatController.isAnimating) {
      _beatController.repeat(reverse: true);
    }
  }

  Widget _buildCard({
    required bool connected,
    required int? bpm,
  }) {
    final heartColor =
    connected ? Colors.red.shade600 : Colors.red.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Color(0xFF313b36),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: heartColor.withOpacity(0.2),
            ),
            child: ScaleTransition(
              scale: connected
                  ? _scaleAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Icon(
                  connected ? Icons.favorite : Icons.favorite_border,
                  size: 65,
                  color: connected ? Colors.red.shade600 : Colors.grey,
                ),
              ),
          ),

          const SizedBox(height: 24),

          Text(
            connected && bpm != null ? bpm.toString() : '--',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'BPM',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            connected
                ? 'Live heart rate'
                : 'Connect your wearable to see live data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

