// lib/domain/entities/body_measurement.dart
class BodyMeasurement {
  final int? id;
  final String userId;
  final DateTime date;
  final double? weight;
  final double? neckCircumference;
  final double? waistCircumference;
  final double? hipCircumference;
  final double? bodyFatPercentage;
  final DateTime createdAt;

  BodyMeasurement({
    this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.neckCircumference,
    this.waistCircumference,
    this.hipCircumference,
    this.bodyFatPercentage,
    required this.createdAt,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      neckCircumference: (json['neck_circumference'] as num?)?.toDouble(),
      waistCircumference: (json['waist_circumference'] as num?)?.toDouble(),
      hipCircumference: (json['hip_circumference'] as num?)?.toDouble(),
      bodyFatPercentage: (json['body_fat_percentage'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'weight': weight,
      'neck_circumference': neckCircumference,
      'waist_circumference': waistCircumference,
      'hip_circumference': hipCircumference,
      'body_fat_percentage': bodyFatPercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}