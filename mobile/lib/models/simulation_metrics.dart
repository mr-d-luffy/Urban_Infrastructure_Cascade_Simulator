class SimulationMetrics {
  final int affectedServices;
  final int cascadeDepth;
  final int recoveryTime;
  final double impactPercentage;
  final int criticalServicesAffected;
  final int totalServices;

  const SimulationMetrics({
    required this.affectedServices,
    required this.cascadeDepth,
    required this.recoveryTime,
    required this.impactPercentage,
    required this.criticalServicesAffected,
    required this.totalServices,
  });

  factory SimulationMetrics.empty({int total = 8}) {
    return SimulationMetrics(
      affectedServices: 0,
      cascadeDepth: 0,
      recoveryTime: 0,
      impactPercentage: 0.0,
      criticalServicesAffected: 0,
      totalServices: total,
    );
  }

  factory SimulationMetrics.fromJson(Map<String, dynamic> json) {
    return SimulationMetrics(
      affectedServices: (json['affectedServices'] as num?)?.toInt() ?? 0,
      cascadeDepth: (json['cascadeDepth'] as num?)?.toInt() ?? 0,
      recoveryTime: (json['recoveryTime'] as num?)?.toInt() ?? 0,
      impactPercentage: (json['impactPercentage'] as num?)?.toDouble() ?? 0.0,
      criticalServicesAffected: (json['criticalServicesAffected'] as num?)?.toInt() ?? 0,
      totalServices: (json['totalServices'] as num?)?.toInt() ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'affectedServices': affectedServices,
      'cascadeDepth': cascadeDepth,
      'recoveryTime': recoveryTime,
      'impactPercentage': impactPercentage,
      'criticalServicesAffected': criticalServicesAffected,
      'totalServices': totalServices,
    };
  }

  SimulationMetrics copyWith({
    int? affectedServices,
    int? cascadeDepth,
    int? recoveryTime,
    double? impactPercentage,
    int? criticalServicesAffected,
    int? totalServices,
  }) {
    return SimulationMetrics(
      affectedServices: affectedServices ?? this.affectedServices,
      cascadeDepth: cascadeDepth ?? this.cascadeDepth,
      recoveryTime: recoveryTime ?? this.recoveryTime,
      impactPercentage: impactPercentage ?? this.impactPercentage,
      criticalServicesAffected: criticalServicesAffected ?? this.criticalServicesAffected,
      totalServices: totalServices ?? this.totalServices,
    );
  }
}
