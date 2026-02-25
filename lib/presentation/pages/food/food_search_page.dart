import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/food.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/food/food_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodSearchPage extends StatefulWidget {
  final String mealType;
  final DateTime date;
  final bool isAddingToRecipe;

  const FoodSearchPage({
    super.key,
    required this.mealType,
    required this.date,
    this.isAddingToRecipe = false,
  });

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _performSearch('');
    setState(() => _isLoading = false);
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    await _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;

      final results = await AppRepositoryProvider.food.searchFoodsAndRecipes(
        authState.user!.id,
        query,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск продуктов'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
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
                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Ничего не найдено',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final isRecipe = item['type'] == 'recipe';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: isRecipe
                                  ? const Icon(Icons.restaurant_menu, color: Colors.green)
                                  : const Icon(Icons.fastfood, color: Colors.blue),
                              title: Text(
                                item['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${item['calories'].toStringAsFixed(1)} ккал/100г • '
                                '${item['proteins'].toStringAsFixed(1)}г б • '
                                '${item['fats'].toStringAsFixed(1)}г ж • '
                                '${item['carbs'].toStringAsFixed(1)}г у',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _selectItem(item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _selectItem(Map<String, dynamic> item) {
    if (widget.isAddingToRecipe) {
      // Для добавления в рецепт возвращаем продукт
      Navigator.pop(context, {
        'food': Food(
          id: item['id'],
          name: item['name'],
          calories: item['calories'],
          proteins: item['proteins'],
          fats: item['fats'],
          carbs: item['carbs'],
          isCustom: item['isCustom'] ?? false,
          isRecipe: item['isRecipe'] ?? false,
          recipeId: item['recipeId'],
        ),
      });
    } else {
      // Для добавления в прием пищи
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodDetailPage(
            food: item,
            mealType: widget.mealType,
            date: widget.date,
          ),
        ),
      ).then((_) => Navigator.pop(context));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}