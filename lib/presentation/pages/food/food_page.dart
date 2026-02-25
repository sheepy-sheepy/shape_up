import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/food.dart';
import 'package:shape_up/domain/entities/recipe.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/food/add_food_page.dart';
import 'package:shape_up/presentation/pages/food/add_recipe_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _searchController = TextEditingController();
  List<Food> _customFoods = [];
  List<Recipe> _recipes = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;
      
      final foods = await AppRepositoryProvider.food.getCustomFoods(authState.user!.id);
      final recipes = await AppRepositoryProvider.food.getRecipes(authState.user!.id);
      
      setState(() {
        _customFoods = foods;
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;
      
      final results = await AppRepositoryProvider.food.searchFoodsAndRecipes(
        authState.user!.id,
        query,
      );
      
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск продуктов и рецептов...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isSearching
                    ? _buildSearchResults()
                    : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Ничего не найдено'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final isRecipe = item['type'] == 'recipe';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item['name']),
            subtitle: Text(
              '${item['calories'].toStringAsFixed(1)} ккал/100г, '
              '${item['proteins'].toStringAsFixed(1)}г б, '
              '${item['fats'].toStringAsFixed(1)}г ж, '
              '${item['carbs'].toStringAsFixed(1)}г у',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecipe)
                  const Icon(Icons.restaurant_menu, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _deleteItem(item),
                ),
              ],
            ),
            onTap: () => _editItem(item),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Мои продукты
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Мои продукты',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _navigateToAddFood(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_customFoods.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Нет добавленных продуктов'),
              ),
            )
          else
            ..._customFoods.map((food) => _buildFoodItem(food)),
          
          const Divider(height: 32),
          
          // Мои рецепты
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Мои рецепты',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _navigateToAddRecipe(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_recipes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Нет добавленных рецептов'),
              ),
            )
          else
            ..._recipes.map((recipe) => _buildRecipeItem(recipe)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Food food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(food.name),
        subtitle: Text(
          '${food.calories.toStringAsFixed(1)} ккал, '
          '${food.proteins.toStringAsFixed(1)}г б, '
          '${food.fats.toStringAsFixed(1)}г ж, '
          '${food.carbs.toStringAsFixed(1)}г у',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _deleteFood(food),
        ),
        onTap: () => _editFood(food),
      ),
    );
  }

  Widget _buildRecipeItem(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(recipe.name),
        subtitle: Text(
          '${recipe.caloriesPer100g.toStringAsFixed(1)} ккал/100г, '
          '${recipe.proteinsPer100g.toStringAsFixed(1)}г б, '
          '${recipe.fatsPer100g.toStringAsFixed(1)}г ж, '
          '${recipe.carbsPer100g.toStringAsFixed(1)}г у',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _deleteRecipe(recipe),
            ),
          ],
        ),
        onTap: () => _editRecipe(recipe),
      ),
    );
  }

  Future<void> _navigateToAddFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodPage()),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRecipePage()),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editFood(Food food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFoodPage(food: food),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editRecipe(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecipePage(recipe: recipe),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editItem(Map<String, dynamic> item) async {
    if (item['type'] == 'food') {
      final food = _customFoods.firstWhere((f) => f.id == item['id']);
      await _editFood(food);
    } else {
      final recipe = _recipes.firstWhere((r) => r.id == item['id']);
      await _editRecipe(recipe);
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: Text('Удалить "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      if (item['type'] == 'food') {
        await AppRepositoryProvider.food.deleteCustomFood(item['id']);
      } else {
        await AppRepositoryProvider.food.deleteRecipe(item['id']);
      }
      _loadData();
      _onSearchChanged();
    }
  }

  Future<void> _deleteFood(Food food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление продукта'),
        content: Text('Удалить "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await AppRepositoryProvider.food.deleteCustomFood(food.id!);
      _loadData();
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление рецепта'),
        content: Text('Удалить "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await AppRepositoryProvider.food.deleteRecipe(recipe.id!);
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}