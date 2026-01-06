import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> insertTestStressData({int days = 40}) async {
  final today = DateTime.now();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final random = Random();

  for (int i = 0; i < days; i++) {
    final day = today.subtract(Duration(days: i));
    final dayKey = _dayKey(day);

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('daily_stress_summary')
        .doc(dayKey);

    await docRef.set({
      'dayKey': dayKey,
      'count': random.nextInt(20), // random stress count 0-9
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  print("Inserted $days days of test stress data");
}

String _dayKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
