class FoodEntry {
  final int? id;
  final String userId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final int foodId;
  final double grams;
  final bool isCustomFood;
  final DateTime createdAt;

  FoodEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodId,
    required this.grams,
    this.isCustomFood = false,
    required this.createdAt,
  });

  double get calories => 0; // Will be calculated
  double get proteins => 0;
  double get fats => 0;
  double get carbs => 0;
}