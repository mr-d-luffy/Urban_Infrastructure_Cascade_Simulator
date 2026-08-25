class DisruptionModel {
  final String serviceId;
  final int startTime;
  final double severity;
  final int? duration;

  const DisruptionModel({
    required this.serviceId,
    this.startTime = 0,
    this.severity = 1.0,
    this.duration,
  });

  factory DisruptionModel.fromJson(Map<String, dynamic> json) {
    return DisruptionModel(
      serviceId: json['serviceId'] as String? ?? '',
      startTime: (json['startTime'] as num?)?.toInt() ?? 0,
      severity: (json['severity'] as num?)?.toDouble() ?? 1.0,
      duration: (json['duration'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'startTime': startTime,
      'severity': severity,
      if (duration != null) 'duration': duration,
    };
  }

  DisruptionModel copyWith({
    String? serviceId,
    int? startTime,
    double? severity,
    int? duration,
  }) {
    return DisruptionModel(
      serviceId: serviceId ?? this.serviceId,
      startTime: startTime ?? this.startTime,
      severity: severity ?? this.severity,
      duration: duration ?? this.duration,
    );
  }
}

class ScenarioModel {
  final String id;
  final String name;
  final String? description;
  final int seed;
  final int durationSeconds;
  final int tickSeconds;
  final List<DisruptionModel> disruptions;

  const ScenarioModel({
    required this.id,
    required this.name,
    this.description,
    this.seed = 42003,
    this.durationSeconds = 60,
    this.tickSeconds = 1,
    this.disruptions = const [],
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    final rawDisruptions = json['disruptions'] as List<dynamic>? ?? [];
    return ScenarioModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      seed: (json['seed'] as num?)?.toInt() ?? 42003,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 60,
      tickSeconds: (json['tickSeconds'] as num?)?.toInt() ?? 1,
      disruptions: rawDisruptions
          .map((d) => DisruptionModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'seed': seed,
      'durationSeconds': durationSeconds,
      'tickSeconds': tickSeconds,
      'disruptions': disruptions.map((d) => d.toJson()).toList(),
    };
  }

  ScenarioModel copyWith({
    String? id,
    String? name,
    String? description,
    int? seed,
    int? durationSeconds,
    int? tickSeconds,
    List<DisruptionModel>? disruptions,
  }) {
    return ScenarioModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      seed: seed ?? this.seed,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      tickSeconds: tickSeconds ?? this.tickSeconds,
      disruptions: disruptions ?? this.disruptions,
    );
  }
}
