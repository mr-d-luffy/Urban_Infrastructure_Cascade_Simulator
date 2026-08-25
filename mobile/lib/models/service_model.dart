import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String slug;
  final String category;
  final int criticality;
  final String state; // HEALTHY, DEGRADED, FAILED, RECOVERING, RECOVERED
  final String? description;
  final Offset position;
  final int recoveryDuration;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.criticality,
    this.state = 'HEALTHY',
    this.description,
    this.position = Offset.zero,
    this.recoveryDuration = 6,
  });

  ServiceModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? category,
    int? criticality,
    String? state,
    String? description,
    Offset? position,
    int? recoveryDuration,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      criticality: criticality ?? this.criticality,
      state: state ?? this.state,
      description: description ?? this.description,
      position: position ?? this.position,
      recoveryDuration: recoveryDuration ?? this.recoveryDuration,
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json, {Offset? defaultPosition}) {
    Offset pos = defaultPosition ?? Offset.zero;
    if (json['position'] is Map<String, dynamic>) {
      final p = json['position'] as Map<String, dynamic>;
      pos = Offset(
        (p['x'] as num?)?.toDouble() ?? 0.0,
        (p['y'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return ServiceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      criticality: (json['criticality'] as num?)?.toInt() ?? 3,
      state: (json['state'] as String?) ?? (json['defaultState'] as String?) ?? 'HEALTHY',
      description: json['description'] as String?,
      position: pos,
      recoveryDuration: (json['recoveryDuration'] as num?)?.toInt() ?? 6,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'category': category,
      'criticality': criticality,
      'state': state,
      if (description != null) 'description': description,
      'position': {'x': position.dx, 'y': position.dy},
      'recoveryDuration': recoveryDuration,
    };
  }
}
