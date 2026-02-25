class FoodEntry {
  final int? id;
  final String userId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final int foodId;
  final double grams;
  final bool isCustomFood;
  final bool isRecipe;
  final int? recipeId;
  final DateTime createdAt;

  // Денормализованные данные для быстрого доступа
  final String foodName;
  final double foodCalories;
  final double foodProteins;
  final double foodFats;
  final double foodCarbs;

  FoodEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodId,
    required this.grams,
    this.isCustomFood = false,
    this.isRecipe = false,
    this.recipeId,
    required this.createdAt,
    required this.foodName,
    required this.foodCalories,
    required this.foodProteins,
    required this.foodFats,
    required this.foodCarbs,
  });

  double get calories => foodCalories * grams / 100;
  double get proteins => foodProteins * grams / 100;
  double get fats => foodFats * grams / 100;
  double get carbs => foodCarbs * grams / 100;

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: json['meal_type'] as String,
      foodId: json['food_id'] as int,
      grams: (json['grams'] as num).toDouble(),
      isCustomFood: (json['is_custom_food'] as int? ?? 0) == 1,
      isRecipe: (json['is_recipe'] as int? ?? 0) == 1,
      recipeId: json['recipe_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      foodName: json['food_name'] as String,
      foodCalories: (json['food_calories'] as num).toDouble(),
      foodProteins: (json['food_proteins'] as num).toDouble(),
      foodFats: (json['food_fats'] as num).toDouble(),
      foodCarbs: (json['food_carbs'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'meal_type': mealType,
      'food_id': foodId,
      'grams': grams,
      'is_custom_food': isCustomFood ? 1 : 0,
      'is_recipe': isRecipe ? 1 : 0,
      'recipe_id': recipeId,
      'created_at': createdAt.toIso8601String(),
      'food_name': foodName,
      'food_calories': foodCalories,
      'food_proteins': foodProteins,
      'food_fats': foodFats,
      'food_carbs': foodCarbs,
    };
  }
}