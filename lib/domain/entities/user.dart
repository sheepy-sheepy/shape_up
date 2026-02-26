// lib/domain/entities/user.dart
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final DateTime? birthDate;
  final String? gender;
  final double? height;
  final double? weight;
  final double? neckCircumference;
  final double? waistCircumference;
  final double? hipCircumference;
  final String? goal;
  final String? activityLevel;
  final int? calorieDeficit;
  final int? calorieSurplus;
  final DateTime createdAt;
  final bool hasCompletedInitialParams;

  User({
    required this.id,
    required this.email,
    this.name,
    this.birthDate,
    this.gender,
    this.height,
    this.weight,
    this.neckCircumference,
    this.waistCircumference,
    this.hipCircumference,
    this.goal,
    this.activityLevel,
    this.calorieDeficit,
    this.calorieSurplus,
    required this.createdAt,
    this.hasCompletedInitialParams = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Явно преобразуем has_completed_initial_params
    bool completedParams = false;

    if (json.containsKey('has_completed_initial_params')) {
      final value = json['has_completed_initial_params'];
      if (value is bool) {
        completedParams = value;
      } else if (value is int) {
        completedParams = value == 1;
      } else if (value is String) {
        completedParams = value.toLowerCase() == 'true' || value == '1';
      }
    }

    debugPrint(
        '🔄 Converting has_completed_initial_params: ${json['has_completed_initial_params']} -> $completedParams');

    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      neckCircumference: (json['neck_circumference'] as num?)?.toDouble(),
      waistCircumference: (json['waist_circumference'] as num?)?.toDouble(),
      hipCircumference: (json['hip_circumference'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      activityLevel: json['activity_level'] as String?,
      calorieDeficit: json['calorie_deficit'] as int?,
      calorieSurplus: json['calorie_surplus'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      hasCompletedInitialParams: completedParams,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'neck_circumference': neckCircumference,
      'waist_circumference': waistCircumference,
      'hip_circumference': hipCircumference,
      'goal': goal,
      'activity_level': activityLevel,
      'calorie_deficit': calorieDeficit,
      'calorie_surplus': calorieSurplus,
      'created_at': createdAt.toIso8601String(),
      'has_completed_initial_params': hasCompletedInitialParams ? 1 : 0,
    };
  }
}
