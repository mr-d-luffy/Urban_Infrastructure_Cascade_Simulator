import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/dependency_model.dart';
import '../models/scenario_model.dart';
import '../models/service_model.dart';
import '../models/simulation_event.dart';
import '../models/simulation_metrics.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });
}

class BackendHealth {
  final String status;
  final String storage;
  final bool databaseConnected;

  const BackendHealth({
    required this.status,
    required this.storage,
    required this.databaseConnected,
  });

  factory BackendHealth.fromJson(Map<String, dynamic> json) {
    return BackendHealth(
      status: json['status'] as String? ?? 'ok',
      storage: json['storage'] as String? ?? 'memory',
      databaseConnected: json['databaseConnected'] as bool? ?? false,
    );
  }
}

class ApiService {
  static final http.Client _client = http.Client();

  static Future<ApiResponse<T>> _request<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    T Function(dynamic json)? transform,
  }) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final uri = Uri.parse('$baseUrl$path');
      final headers = {'Content-Type': 'application/json'};

      http.Response response;
      if (method == 'POST') {
        response = await _client
            .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 5));
      } else if (method == 'PUT') {
        response = await _client
            .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 5));
      } else if (method == 'DELETE') {
        response = await _client.delete(uri, headers: headers).timeout(const Duration(seconds: 5));
      } else {
        response = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 5));
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final isSuccess = decoded['success'] as bool? ?? (response.statusCode >= 200 && response.statusCode < 300);

      if (isSuccess) {
        final rawData = decoded['data'] ?? decoded;
        final data = transform != null ? transform(rawData) : rawData as T?;
        return ApiResponse(success: true, data: data);
      } else {
        final errObj = decoded['error'];
        final message = (errObj is Map ? errObj['message'] : errObj?.toString()) ??
            'Server returned error (${response.statusCode})';
        return ApiResponse(success: false, error: message);
      }
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Health check
  static Future<ApiResponse<BackendHealth>> health() async {
    return _request<BackendHealth>(
      '/api/health',
      transform: (json) => BackendHealth.fromJson(json as Map<String, dynamic>),
    );
  }

  // Services
  static Future<ApiResponse<List<ServiceModel>>> getServices() async {
    return _request<List<ServiceModel>>(
      '/api/services',
      transform: (json) => (json as List<dynamic>)
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Dependencies
  static Future<ApiResponse<List<DependencyModel>>> getDependencies() async {
    return _request<List<DependencyModel>>(
      '/api/dependencies',
      transform: (json) => (json as List<dynamic>)
          .map((item) => DependencyModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Scenarios
  static Future<ApiResponse<List<ScenarioModel>>> getScenarios() async {
    return _request<List<ScenarioModel>>(
      '/api/scenarios',
      transform: (json) => (json as List<dynamic>)
          .map((item) => ScenarioModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<ScenarioModel>> createScenario(ScenarioModel scenario) async {
    return _request<ScenarioModel>(
      '/api/scenarios',
      method: 'POST',
      body: scenario.toJson(),
      transform: (json) => ScenarioModel.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<ScenarioModel>> updateScenario(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return _request<ScenarioModel>(
      '/api/scenarios/$id',
      method: 'PUT',
      body: updates,
      transform: (json) => ScenarioModel.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<bool>> deleteScenario(String id) async {
    return _request<bool>(
      '/api/scenarios/$id',
      method: 'DELETE',
      transform: (_) => true,
    );
  }

  // Simulations
  static Future<ApiResponse<Map<String, dynamic>>> runSimulation({
    String? scenarioId,
    List<DisruptionModel>? disruptions,
  }) async {
    return _request<Map<String, dynamic>>(
      '/api/simulations',
      method: 'POST',
      body: {
        'scenarioId': ?scenarioId,
        if (disruptions != null) 'disruptions': disruptions.map((d) => d.toJson()).toList(),
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> recoverSimulation(
    String simulationId,
    List<String> serviceIds,
  ) async {
    return _request<Map<String, dynamic>>(
      '/api/simulations/$simulationId/recovery',
      method: 'POST',
      body: {'serviceIds': serviceIds},
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> resetSimulation(String simulationId) async {
    return _request<Map<String, dynamic>>(
      '/api/simulations/$simulationId/reset',
      method: 'POST',
    );
  }

  static Future<ApiResponse<List<SimulationEvent>>> getEvents(String simulationId) async {
    return _request<List<SimulationEvent>>(
      '/api/simulations/$simulationId/events',
      transform: (json) => (json as List<dynamic>)
          .map((item) => SimulationEvent.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<SimulationMetrics>> getMetrics(String simulationId) async {
    return _request<SimulationMetrics>(
      '/api/simulations/$simulationId/metrics',
      transform: (json) => SimulationMetrics.fromJson(json as Map<String, dynamic>),
    );
  }
}
