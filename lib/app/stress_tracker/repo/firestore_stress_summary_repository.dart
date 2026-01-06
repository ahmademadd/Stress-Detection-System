import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'daily_stress_summary_repository.dart';

class FirestoreStressSummaryRepository implements StressSummaryRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Stream<Map<String, int>> watchDailyStressCounts({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return firestore
        .collection("users")
        .doc(userId)
        .collection("daily_stress_summary")
        .where("dayKey",
        isGreaterThanOrEqualTo: _dayKey(startDate))
        .where("dayKey",
        isLessThanOrEqualTo: _dayKey(endDate))
        .snapshots()
        .map((snapshot) {
      final Map<String, int> result = {};

      for (final doc in snapshot.docs) {
        result[doc['dayKey']] = doc['count'];
      }

      return result;
    });
  }

  /// YYYY-MM-DD (used as document ID)
  String _dayKey(DateTime date) {
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> incrementToday() async {
    final now = DateTime.now();
    final dayKey = _dayKey(now);

    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('daily_stress_summary')
        .doc(dayKey);

    await docRef.set(
      {
        'dayKey': dayKey,
        'count': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
