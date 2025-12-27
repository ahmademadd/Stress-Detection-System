import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stress_sense/app/stress_tracker/repo/stress_event_repository.dart';

import '../model/stress_event.dart';

class FirestoreStressEventRepository implements StressEventRepository {
  final FirebaseFirestore firestore;
  final String userId;

  FirestoreStressEventRepository({
    required this.firestore,
    required this.userId,
  });

  @override
  Future<void> saveStressEvent(StressEvent event) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('stress_events')
        .add(
      event.toMap(),
    );
  }

  @override
  Future<List<StressEvent>> getStressEventsByDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("stress_events")
        .where("prediction", isEqualTo: true)
        .where("timestamp", isGreaterThanOrEqualTo: start)
        .where("timestamp", isLessThan: end)
        .get();

    return snapshot.docs
        .map((d) => StressEvent.fromMap(d.data()))
        .toList();
  }

}
