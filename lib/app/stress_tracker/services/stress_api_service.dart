import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stress_sense/app/stress_tracker/repo/firestore_stress_event_repository.dart';

import '../../../core/notifiers/notifiers.dart';
import '../model/stress_event.dart';
import '../repo/daily_stress_summary_repository.dart';
import '../repo/firestore_stress_summary_repository.dart';
import '../repo/stress_event_repository.dart';
import 'notification_service.dart';

class StressApiService {
  // CONFIGURATION
  // ---------------------------------------------------------------------------
  // TODO: Update this IP to match your current computer's IP (check via ipconfig/ifconfig)
  static const String _baseUrl = "http://192.168.8.5";
  static const Duration _timeout = Duration(seconds: 5); // Increased time for safety

  final StressEventRepository stressEventRepository = FirestoreStressEventRepository();
  final StressSummaryRepository stressSummaryRepository = FirestoreStressSummaryRepository();

  // Use a persistent client to reuse TCP connections (faster for sequential requests)
  final http.Client _client = http.Client();

  /// Generic POST helper to handle timeouts, headers, and error parsing in one place.
  Future<dynamic> _postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$_baseUrl$endpoint");

    try {
      debugPrint("➡️ POST $endpoint");

      final response = await _client
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      debugPrint("✅ Response $endpoint: ${response.statusCode}\n${response.body}");

      if (response.statusCode != 200) {
        throw HttpException("Server returned ${response.statusCode}: ${response.body}");
      }

      // Handle Python 'nan' which is invalid JSON in Dart
      final cleanBody = response.body.replaceAll('nan', '0');
      return jsonDecode(cleanBody);

    } on TimeoutException {
      debugPrint("❌ Timeout on $endpoint");
      throw Exception("Connection timed out. Server is taking too long.");
    } on SocketException {
      debugPrint("❌ SocketException on $endpoint");
      throw Exception("Network error. Cannot reach $_baseUrl. Check IP and Firewall.");
    } catch (e) {
      debugPrint("❌ Error on $endpoint: $e");
      rethrow;
    }
  }

  Future<List<double>> preprocessData({
    required List<double> accX,
    required List<double> accY,
    required List<double> accZ,
    required List<double> bvp,
    required List<double> eda,
    required List<double> temp
  }) async {
    // Sanitize inputs: Ensure no NaNs are sent to server (optional safety)
    // You could add a helper here if your sensors frequent return null/nan.

    final body = {
      "acc_x": {"valuelist": accX},
      "acc_y": {"valuelist": accY},
      "acc_z": {"valuelist": accZ},
      "bvp":   {"valuelist": bvp},
      "eda":   {"valuelist": eda},
      "temp":  {"valuelist": temp},
    };

    try {
      final rawResponse = await _postRequest(":8004/preprocess/", body);

      // Safe casting
      final List<dynamic> rawList = rawResponse as List<dynamic>;
      return rawList.map((e) => (e as num).toDouble()).toList();

    } catch (e) {
      // Ensure we reset the state if preprocessing fails
      AppData.isPredictingStress.value = false;
      rethrow;
    }
  }

  Future<int> predictStress(List<double> features) async {
    try {
      final body = {
        "valuelist": features,
      };

      // Note: Your port changed in the original code (8004 vs 8002).
      // Ensure this port matches your Python setup.
      final rawResponse = await _postRequest(":8002/predict/", body);

      // Depending on if server returns an int directly or a JSON object
      // If server returns raw "1", jsonDecode treats it as int.
      if (rawResponse is int) return rawResponse;
      if (rawResponse is String) return int.parse(rawResponse);

      return 0; // Default fallback

    } catch (e) {
      AppData.isPredictingStress.value = false;
      rethrow;
    }
  }

  Future<void> stressPredictionPipeline({
    required List<double> accX,
    required List<double> accY,
    required List<double> accZ,
    required List<double> bvp,
    required List<double> eda,
    required List<double> temp,
  }) async {
    try {
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
        await NotificationService().showNotification(
          title: "Stress Detected!",
          body: "A stress episode has been detected for the child.",
        );

        // Save event
        final event = StressEvent(
          timestamp: DateTime.now(),
          prediction: true,
        );
        await stressEventRepository.saveStressEvent(event);
        await stressSummaryRepository.incrementToday();

      } else {
        AppData.isStressed.value = false;
      }
    } catch (e) {
      // Catch-all for pipeline errors to ensure UI doesn't hang
      debugPrint("⚠️ Pipeline failed: $e");
      AppData.isPredictingStress.value = false;
    } finally {
      // Always reset the loading state
      AppData.isPredictingStress.value = false;
    }
  }

  // Call this when the app closes to clean up connections
  void dispose() {
    _client.close();
  }
}