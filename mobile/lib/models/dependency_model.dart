class DependencyModel {
  final String id;
  final String sourceServiceId;
  final String targetServiceId;
  final double dependencyStrength;

  const DependencyModel({
    required this.id,
    required this.sourceServiceId,
    required this.targetServiceId,
    this.dependencyStrength = 1.0,
  });

  factory DependencyModel.fromJson(Map<String, dynamic> json) {
    return DependencyModel(
      id: json['id'] as String? ?? '',
      sourceServiceId: json['sourceServiceId'] as String? ?? '',
      targetServiceId: json['targetServiceId'] as String? ?? '',
      dependencyStrength: (json['dependencyStrength'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceServiceId': sourceServiceId,
      'targetServiceId': targetServiceId,
      'dependencyStrength': dependencyStrength,
    };
  }
}
