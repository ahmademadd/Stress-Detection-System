import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:stress_sense/app/stress_tracker/repo/firestore_stress_event_repository.dart';

import '../../../core/notifiers/notifiers.dart';
import '../model/stress_event.dart';
import '../repo/daily_stress_summary_repository.dart';
import '../repo/firestore_stress_summary_repository.dart';
import '../repo/stress_event_repository.dart';

class StressApiService {
  final StressEventRepository stressEventRepository =
  FirestoreStressEventRepository(
    firestore: FirebaseFirestore.instance,
    userId: FirebaseAuth.instance.currentUser!.uid,
  );
  final StressSummaryRepository stressSummaryRepository =
  FirestoreStressSummaryRepository(
    firestore: FirebaseFirestore.instance,
    userId: FirebaseAuth.instance.currentUser!.uid,
  );

  Future<List<double>> preprocessData({
    required List<double> accX,
    required List<double> accY,
    required List<double> accZ,
    required List<double> bvp,
    required List<double> eda,
    required List<double> temp
  }) async {
    final preprocessBody = {
      "acc_x": {"valuelist": accX},
      "acc_y": {"valuelist": accY},
      "acc_z": {"valuelist": accZ},
      "bvp":   {"valuelist": bvp},
      "eda":   {"valuelist": eda},
      "temp":  {"valuelist": temp},
    };
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8004/preprocess/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(preprocessBody),
    );

    if (response.statusCode != 200) {
      throw Exception("Preprocessing failed");
    }

    final List<dynamic> raw = jsonDecode(response.body);
    final List<double> features = raw.map((e) => (e as num).toDouble()).toList();
    return features;
  }

  Future<int> predictStress(List<double> features) async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8002/predict/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "valuelist": features,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Prediction failed");
    }

    return int.parse(response.body);
  }

  Future<void> stressPredictionPipeline({
    required List<double> accX,
    required List<double> accY,
    required List<double> accZ,
    required List<double> bvp,
    required List<double> eda,
    required List<double> temp,
  }) async {
    final features = await preprocessData(
      accX: accX,
      accY: accY,
      accZ: accZ,
      bvp: bvp,
      eda: eda,
      temp: temp,
    );
    final prediction = await predictStress(features);
    if (prediction == 1) {
      AppData.iStressed.value = true;
      final event = StressEvent(
        timestamp: DateTime.now(),
        prediction: true,
      );
      await stressEventRepository.saveStressEvent(event);
      await stressSummaryRepository.incrementToday();

    } else {
      AppData.iStressed.value = false;
    }
  }
}
