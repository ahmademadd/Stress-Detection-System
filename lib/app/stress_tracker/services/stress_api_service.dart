import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:stress_sense/app/stress_tracker/repo/firestore_stress_event_repository.dart';

import '../../../core/notifiers/notifiers.dart';
import '../model/stress_event.dart';
import '../repo/daily_stress_summary_repository.dart';
import '../repo/firestore_stress_summary_repository.dart';
import '../repo/stress_event_repository.dart';

class StressApiService {
  final StressEventRepository stressEventRepository = FirestoreStressEventRepository();
  final StressSummaryRepository stressSummaryRepository = FirestoreStressSummaryRepository();

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
    try {
      debugPrint("➡️ Sending request to server PREPROCESS");

      final response = await http
          .post(
        Uri.parse("http://192.168.8.5:8004/preprocess/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(preprocessBody),
      )
          .timeout(const Duration(seconds: 5));
      final fixedBody = response.body.replaceAll('nan', '0');

      debugPrint("✅ Response received PREPROCESS");
      debugPrint("Status PREPROCESS: ${response.statusCode}");
      debugPrint("Body PREPROCESS: $fixedBody");

      if (response.statusCode != 200) {
        AppData.isPredictingStress.value = false;
        throw Exception("Server error: ${response.statusCode}");
      }

      final List<dynamic> raw = jsonDecode(fixedBody);
      return raw.map((e) => (e as num).toDouble()).toList();

    } on TimeoutException {
      AppData.isPredictingStress.value = false;
      throw Exception("Connection timeout — server unreachable");
    } on SocketException {
      AppData.isPredictingStress.value = false;
      throw Exception("Network error — no route to host");
    } catch (e) {
      AppData.isPredictingStress.value = false;
      rethrow;
    }

  }

  Future<int> predictStress(List<double> features) async {
    debugPrint("➡️ Sending request to server PREDICT");

    final response = await http.post(
      Uri.parse("http://192.168.8.5:8002/predict/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "valuelist": features,
      }),
    );
    debugPrint("✅ Response received PREDICT");
    debugPrint("Status PREDICT: ${response.statusCode}");
    debugPrint("Body PREDICT: ${response.body}");

    if (response.statusCode != 200) {
      AppData.isPredictingStress.value = false;
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
      AppData.isStressed.value = true;
      final event = StressEvent(
        timestamp: DateTime.now(),
        prediction: true,
      );
      await stressEventRepository.saveStressEvent(event);
      await stressSummaryRepository.incrementToday();

    } else {
      AppData.isStressed.value = false;
    }
  }
}
