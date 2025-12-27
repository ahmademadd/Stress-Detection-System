class StressEvent {
  final DateTime timestamp;
  final bool prediction;

  StressEvent({
    required this.timestamp,
    required this.prediction,
  });

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp.toUtc(),
      "prediction": prediction,
    };
  }

  static StressEvent fromMap(Map<String, dynamic> map) {
    return StressEvent(
      timestamp: (map['timestamp']).toDate(),
      prediction: map['prediction'] as bool,
    );
  }
}
