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
}