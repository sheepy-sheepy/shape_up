class Food {
  final int? id;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final bool isCustom;
  final String? userId;
  final DateTime? createdAt;
  final bool isRecipe;
  final int? recipeId;

  Food({
    this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.isCustom = false,
    this.userId,
    this.createdAt,
    this.isRecipe = false,
    this.recipeId,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int?,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      isCustom: (json['is_custom'] as int? ?? 0) == 1,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isRecipe: (json['is_recipe'] as int? ?? 0) == 1,
      recipeId: json['recipe_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'is_custom': isCustom ? 1 : 0,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'is_recipe': isRecipe ? 1 : 0,
      'recipe_id': recipeId,
    };
  }
}