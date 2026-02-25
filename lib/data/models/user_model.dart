// lib/data/models/user_model.dart
class UserModel {
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

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
      hasCompletedInitialParams: json['has_completed_initial_params'] as bool? ?? false,
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
      'has_completed_initial_params': hasCompletedInitialParams,
    };
  }
}