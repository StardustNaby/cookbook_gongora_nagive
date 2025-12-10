import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/step.dart';
import '../providers/recipe_providers.dart';

class AddEditRecipeScreen extends ConsumerStatefulWidget {
  final Recipe? recipe;
  final String? recipeId;

  const AddEditRecipeScreen({
    super.key,
    this.recipe,
    this.recipeId,
  });

  @override
  ConsumerState<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends ConsumerState<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prepTimeController = TextEditingController();
  
  Difficulty _difficulty = Difficulty.medium;
  final List<Ingredient> _ingredients = [];
  final List<Step> _steps = [];
  
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();
  
  final _stepDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _loadRecipeData(widget.recipe!);
    } else if (widget.recipeId != null) {
      // Load recipe by ID - will be handled in build method
    }
  }

  void _loadRecipeData(Recipe recipe) {
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description ?? '';
    _imageUrlController.text = recipe.imageUrl ?? '';
    _prepTimeController.text = recipe.prepTimeMinutes.toString();
    _difficulty = recipe.difficulty;
    _ingredients.clear();
    _ingredients.addAll(recipe.ingredients);
    _steps.clear();
    _steps.addAll(recipe.steps);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _ingredientNameController.dispose();
    _ingredientQuantityController.dispose();
    _ingredientUnitController.dispose();
    _stepDescriptionController.dispose();
    super.dispose();
  }

  void _addIngredient([Recipe? recipe]) {
    if (_ingredientNameController.text.isNotEmpty &&
        _ingredientQuantityController.text.isNotEmpty &&
        _ingredientUnitController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(
          Ingredient(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            recipeId: recipe?.id ?? widget.recipe?.id ?? widget.recipeId ?? '',
            name: _ingredientNameController.text,
            quantity: double.tryParse(_ingredientQuantityController.text) ?? 0,
            unit: _ingredientUnitController.text,
          ),
        );
        _ingredientNameController.clear();
        _ingredientQuantityController.clear();
        _ingredientUnitController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep([Recipe? recipe]) {
    if (_stepDescriptionController.text.isNotEmpty) {
      setState(() {
        _steps.add(
          Step(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            recipeId: recipe?.id ?? widget.recipe?.id ?? widget.recipeId ?? '',
            stepNumber: _steps.length + 1,
            description: _stepDescriptionController.text,
          ),
        );
        _stepDescriptionController.clear();
      });
    }
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Reorder steps
      for (int i = 0; i < _steps.length; i++) {
        _steps[i] = Step(
          id: _steps[i].id,
          recipeId: _steps[i].recipeId,
          stepNumber: i + 1,
          description: _steps[i].description,
        );
      }
    });
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final currentRecipe = recipe ?? widget.recipe;
      final newRecipe = Recipe(
        id: currentRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 0,
        difficulty: _difficulty,
        isFavorite: currentRecipe?.isFavorite ?? false,
        createdAt: currentRecipe?.createdAt ?? now,
        updatedAt: now,
        ingredients: _ingredients,
        steps: _steps,
      );

      final notifier = ref.read(recipeNotifierProvider.notifier);
      
      if (currentRecipe == null) {
        await notifier.createRecipe(newRecipe);
      } else {
        await notifier.updateRecipe(newRecipe);
      }

      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have a recipeId but no recipe, load it
    if (widget.recipeId != null && widget.recipe == null) {
      final recipeAsync = ref.watch(recipeByIdProvider(widget.recipeId!));
      
      return recipeAsync.when(
        data: (recipe) {
          // Load recipe data if not already loaded
          if (_nameController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadRecipeData(recipe);
            });
          }
          return _buildForm(context, recipe);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error: $error')),
        ),
      );
    }
    
    return _buildForm(context, widget.recipe);
  }

  Widget _buildForm(BuildContext context, Recipe? recipe) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe == null ? 'Nueva Receta' : 'Editar Receta'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la receta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Tiempo (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<Difficulty>(
                      value: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Dificultad',
                        border: OutlineInputBorder(),
                      ),
                      items: Difficulty.values.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _difficulty = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              // Ingredients section
              const SizedBox(height: 24),
              Text(
                'Ingredientes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(ingredient.name),
                    subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
              // Steps section
              const SizedBox(height: 24),
              Text(
                'Pasos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ..._steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${step.stepNumber}'),
                    ),
                    title: Text(step.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeStep(index),
                    ),
                  ),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stepDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción del paso',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addStep(recipe),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(recipe == null ? 'Crear Receta' : 'Actualizar Receta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

