class Recipe {
  final int? id;
  final String name;
  final String userId;
  final List<RecipeIngredient> ingredients;
  final double totalCalories;
  final double totalProteins;
  final double totalFats;
  final double totalCarbs;
  final double totalGrams;
  final DateTime? createdAt;

  Recipe({
    this.id,
    required this.name,
    required this.userId,
    required this.ingredients,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalFats,
    required this.totalCarbs,
    required this.totalGrams,
    this.createdAt,
  });

  double get caloriesPer100g => totalGrams > 0 ? (totalCalories * 100 / totalGrams) : 0;
  double get proteinsPer100g => totalGrams > 0 ? (totalProteins * 100 / totalGrams) : 0;
  double get fatsPer100g => totalGrams > 0 ? (totalFats * 100 / totalGrams) : 0;
  double get carbsPer100g => totalGrams > 0 ? (totalCarbs * 100 / totalGrams) : 0;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int?,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      ingredients: (json['ingredients'] as List? ?? [])
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      totalCalories: (json['total_calories'] as num).toDouble(),
      totalProteins: (json['total_proteins'] as num).toDouble(),
      totalFats: (json['total_fats'] as num).toDouble(),
      totalCarbs: (json['total_carbs'] as num).toDouble(),
      totalGrams: (json['total_grams'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'total_calories': totalCalories,
      'total_proteins': totalProteins,
      'total_fats': totalFats,
      'total_carbs': totalCarbs,
      'total_grams': totalGrams,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class RecipeIngredient {
  final int? id;
  final int recipeId;
  final int foodId;
  final double grams;
  final bool isCustomFood;
  final String foodName;
  final double foodCalories;
  final double foodProteins;
  final double foodFats;
  final double foodCarbs;

  RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.foodId,
    required this.grams,
    this.isCustomFood = false,
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

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as int?,
      recipeId: json['recipe_id'] as int,
      foodId: json['food_id'] as int,
      grams: (json['grams'] as num).toDouble(),
      isCustomFood: (json['is_custom_food'] as int? ?? 0) == 1,
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
      'recipe_id': recipeId,
      'food_id': foodId,
      'grams': grams,
      'is_custom_food': isCustomFood ? 1 : 0,
      'food_name': foodName,
      'food_calories': foodCalories,
      'food_proteins': foodProteins,
      'food_fats': foodFats,
      'food_carbs': foodCarbs,
    };
  }
}