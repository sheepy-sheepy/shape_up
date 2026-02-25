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
  });

  // For 100g serving
  Map<String, double> get macrosPer100g => {
    'calories': calories,
    'proteins': proteins,
    'fats': fats,
    'carbs': carbs,
  };
}