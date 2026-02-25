import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/domain/entities/food.dart';
import 'package:shape_up/domain/entities/recipe.dart';

class FoodRepository {
  final AppDatabase database;

  FoodRepository({
    required this.database,
  });

  // Foods
  Future<List<Food>> getAllFoods(String userId, {String? searchQuery}) async {
    final db = await database.database;
    
    String query = '''
      SELECT * FROM foods 
      WHERE (is_custom = 0) OR (is_custom = 1 AND user_id = ?)
    ''';
    List<dynamic> params = [userId];
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND name LIKE ?';
      params.add('%$searchQuery%');
    }
    
    query += ' ORDER BY is_custom DESC, name ASC';
    
    final result = await db.rawQuery(query, params);
    
    return result.map((json) => Food.fromJson(json)).toList();
  }

  Future<List<Food>> getCustomFoods(String userId) async {
    final db = await database.database;
    
    final result = await db.query(
      'foods',
      where: 'is_custom = 1 AND user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    
    return result.map((json) => Food.fromJson(json)).toList();
  }

  Future<Food> getFoodById(int foodId) async {
    final db = await database.database;
    
    final result = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [foodId],
    );
    
    if (result.isEmpty) throw Exception('Food not found');
    
    return Food.fromJson(result.first);
  }

  Future<int> addCustomFood(Food food) async {
    final db = await database.database;
    
    return await db.insert('foods', {
      'name': food.name,
      'calories': food.calories,
      'proteins': food.proteins,
      'fats': food.fats,
      'carbs': food.carbs,
      'is_custom': 1,
      'user_id': food.userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateCustomFood(Food food) async {
    final db = await database.database;
    
    return await db.update(
      'foods',
      {
        'name': food.name,
        'calories': food.calories,
        'proteins': food.proteins,
        'fats': food.fats,
        'carbs': food.carbs,
      },
      where: 'id = ? AND is_custom = 1',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteCustomFood(int foodId) async {
    final db = await database.database;
    
    return await db.delete(
      'foods',
      where: 'id = ? AND is_custom = 1',
      whereArgs: [foodId],
    );
  }

  // Recipes
  Future<List<Recipe>> getRecipes(String userId, {String? searchQuery}) async {
    final db = await database.database;
    
    String query = 'SELECT * FROM recipes WHERE user_id = ?';
    List<dynamic> params = [userId];
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND name LIKE ?';
      params.add('%$searchQuery%');
    }
    
    query += ' ORDER BY name ASC';
    
    final recipesResult = await db.rawQuery(query, params);
    final recipes = <Recipe>[];
    
    for (var recipeJson in recipesResult) {
      final ingredients = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeJson['id']],
      );
      
      final ingredientsList = await Future.wait(ingredients.map((ing) async {
        final food = await getFoodById(ing['food_id'] as int);
        return RecipeIngredient(
          id: ing['id'] as int,
          recipeId: ing['recipe_id'] as int,
          foodId: ing['food_id'] as int,
          grams: (ing['grams'] as num).toDouble(),
          isCustomFood: (ing['is_custom_food'] as int) == 1,
          foodName: food.name,
          foodCalories: food.calories,
          foodProteins: food.proteins,
          foodFats: food.fats,
          foodCarbs: food.carbs,
        );
      }));
      
      recipes.add(Recipe(
        id: recipeJson['id'] as int,
        name: recipeJson['name'] as String,
        userId: recipeJson['user_id'] as String,
        ingredients: ingredientsList,
        totalCalories: (recipeJson['total_calories'] as num).toDouble(),
        totalProteins: (recipeJson['total_proteins'] as num).toDouble(),
        totalFats: (recipeJson['total_fats'] as num).toDouble(),
        totalCarbs: (recipeJson['total_carbs'] as num).toDouble(),
        totalGrams: (recipeJson['total_grams'] as num).toDouble(),
        createdAt: recipeJson['created_at'] != null
            ? DateTime.parse(recipeJson['created_at'] as String)
            : null,
      ));
    }
    
    return recipes;
  }

  Future<Recipe?> getRecipeById(int recipeId) async {
    final db = await database.database;
    
    final recipeResult = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );
    
    if (recipeResult.isEmpty) return null;
    
    final recipeJson = recipeResult.first;
    
    final ingredients = await db.query(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    
    final ingredientsList = await Future.wait(ingredients.map((ing) async {
      final food = await getFoodById(ing['food_id'] as int);
      return RecipeIngredient(
        id: ing['id'] as int,
        recipeId: ing['recipe_id'] as int,
        foodId: ing['food_id'] as int,
        grams: (ing['grams'] as num).toDouble(),
        isCustomFood: (ing['is_custom_food'] as int) == 1,
        foodName: food.name,
        foodCalories: food.calories,
        foodProteins: food.proteins,
        foodFats: food.fats,
        foodCarbs: food.carbs,
      );
    }));
    
    return Recipe(
      id: recipeJson['id'] as int,
      name: recipeJson['name'] as String,
      userId: recipeJson['user_id'] as String,
      ingredients: ingredientsList,
      totalCalories: (recipeJson['total_calories'] as num).toDouble(),
      totalProteins: (recipeJson['total_proteins'] as num).toDouble(),
      totalFats: (recipeJson['total_fats'] as num).toDouble(),
      totalCarbs: (recipeJson['total_carbs'] as num).toDouble(),
      totalGrams: (recipeJson['total_grams'] as num).toDouble(),
      createdAt: recipeJson['created_at'] != null
          ? DateTime.parse(recipeJson['created_at'] as String)
          : null,
    );
  }

  Future<int> addRecipe(Recipe recipe) async {
    final db = await database.database;
    
    return await db.transaction((txn) async {
      final recipeId = await txn.insert('recipes', {
        'name': recipe.name,
        'user_id': recipe.userId,
        'total_calories': recipe.totalCalories,
        'total_proteins': recipe.totalProteins,
        'total_fats': recipe.totalFats,
        'total_carbs': recipe.totalCarbs,
        'total_grams': recipe.totalGrams,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      for (var ingredient in recipe.ingredients) {
        await txn.insert('recipe_ingredients', {
          'recipe_id': recipeId,
          'food_id': ingredient.foodId,
          'grams': ingredient.grams,
          'is_custom_food': ingredient.isCustomFood ? 1 : 0,
        });
      }
      
      return recipeId;
    });
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database.database;
    
    return await db.transaction((txn) async {
      await txn.update(
        'recipes',
        {
          'name': recipe.name,
          'total_calories': recipe.totalCalories,
          'total_proteins': recipe.totalProteins,
          'total_fats': recipe.totalFats,
          'total_carbs': recipe.totalCarbs,
          'total_grams': recipe.totalGrams,
        },
        where: 'id = ?',
        whereArgs: [recipe.id],
      );
      
      await txn.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipe.id],
      );
      
      for (var ingredient in recipe.ingredients) {
        await txn.insert('recipe_ingredients', {
          'recipe_id': recipe.id,
          'food_id': ingredient.foodId,
          'grams': ingredient.grams,
          'is_custom_food': ingredient.isCustomFood ? 1 : 0,
        });
      }
      
      return recipe.id!;
    });
  }

  Future<int> deleteRecipe(int recipeId) async {
    final db = await database.database;
    
    return await db.transaction((txn) async {
      await txn.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );
      
      return await txn.delete(
        'recipes',
        where: 'id = ?',
        whereArgs: [recipeId],
      );
    });
  }

  // Combined search
  Future<List<Map<String, dynamic>>> searchFoodsAndRecipes(
    String userId, 
    String query
  ) async {
    final foods = await getAllFoods(userId, searchQuery: query);
    final recipes = await getRecipes(userId, searchQuery: query);
    
    final results = <Map<String, dynamic>>[];
    
    results.addAll(foods.map((f) => {
      'type': 'food',
      'id': f.id,
      'name': f.name,
      'calories': f.calories,
      'proteins': f.proteins,
      'fats': f.fats,
      'carbs': f.carbs,
      'isCustom': f.isCustom,
      'isRecipe': false,
    }));
    
    results.addAll(recipes.map((r) => {
      'type': 'recipe',
      'id': r.id,
      'name': r.name,
      'calories': r.caloriesPer100g,
      'proteins': r.proteinsPer100g,
      'fats': r.fatsPer100g,
      'carbs': r.carbsPer100g,
      'isCustom': true,
      'isRecipe': true,
      'recipeId': r.id,
    }));
    
    results.sort((a, b) => a['name'].compareTo(b['name']));
    
    return results;
  }
}