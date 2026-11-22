import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../data/models/ai_planner_models.dart';

class AiPlannerResult {
  final bool success;
  final String? message;
  final List<AiPlannedPackage> packages;

  AiPlannerResult({
    required this.success,
    this.message,
    this.packages = const [],
  });
}

class AiPlannerService {
  AiPlannerService._();
  static final AiPlannerService instance = AiPlannerService._();

  Future<AiPlannerResult> generatePlan(AiPlannerRequest request) async {
    final bodyJson = jsonEncode(request.toJson());
    final candidateUrls = ApiConfig.candidateAiPlannerUrls;

    String? lastErrorMessage;

    for (final url in candidateUrls) {
      try {
        if (kDebugMode) {
          debugPrint('[AiPlannerService] Mengirim request optimasi ke: $url');
        }

        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: bodyJson,
            )
            .timeout(const Duration(seconds: 12));

        if (kDebugMode) {
          debugPrint(
              '[AiPlannerService] Respons status: ${response.statusCode}');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 200 && decoded['success'] == true) {
          final data = decoded['data'] as Map<String, dynamic>? ?? {};
          final rawPackages = (data['packages'] as List<dynamic>?) ?? [];

          final baseUrl = url.replaceAll('/api/ai-planner/generate', '');
          final packages = rawPackages
              .map((pkg) => AiPlannedPackage.fromJson(
                    pkg as Map<String, dynamic>,
                    baseUrl: baseUrl,
                    totalBudget: request.budget,
                    pax: request.pax,
                  ))
              .toList();

          return AiPlannerResult(
            success: true,
            packages: packages,
          );
        } else {
          lastErrorMessage = decoded['message']?.toString() ??
              'Gagal menghasilkan rencana paket katering.';
          // If status is 400 or 422 (validation / infeasible), don't retry other URLs as error is from server logic
          if (response.statusCode == 400 || response.statusCode == 422) {
            return AiPlannerResult(
              success: false,
              message: lastErrorMessage,
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AiPlannerService] Gagal menghubungi $url: $e');
        }
        lastErrorMessage = 'Gagal terhubung ke server backend: $e';
      }
    }

    return AiPlannerResult(
      success: false,
      message: lastErrorMessage ?? 'Tidak dapat terhubung ke server AI Planner.',
    );
  }
}
