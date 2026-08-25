class SimulationEvent {
  final int simulationTime;
  final String serviceId;
  final String eventType; // FAILURE, DEGRADATION, PROPAGATION, RECOVERY_STARTED, RECOVERY_COMPLETED, STABILIZED
  final String? previousState;
  final String? newState;
  final String? reason;

  const SimulationEvent({
    required this.simulationTime,
    required this.serviceId,
    required this.eventType,
    this.previousState,
    this.newState,
    this.reason,
  });

  String get friendlyEventType {
    switch (eventType) {
      case 'FAILURE':
        return 'Critical Failure';
      case 'DEGRADATION':
        return 'Service Degraded';
      case 'PROPAGATION':
        return 'Cascade Propagation';
      case 'RECOVERY_STARTED':
        return 'Recovery Started';
      case 'RECOVERY_COMPLETED':
        return 'Recovery Completed';
      case 'STABILIZED':
        return 'System Stabilized';
      default:
        return eventType;
    }
  }

  factory SimulationEvent.fromJson(Map<String, dynamic> json) {
    return SimulationEvent(
      simulationTime: (json['simulationTime'] as num?)?.toInt() ?? 0,
      serviceId: json['serviceId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? 'PROPAGATION',
      previousState: json['previousState'] as String?,
      newState: json['newState'] as String?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simulationTime': simulationTime,
      'serviceId': serviceId,
      'eventType': eventType,
      if (previousState != null) 'previousState': previousState,
      if (newState != null) 'newState': newState,
      if (reason != null) 'reason': reason,
    };
  }
}
