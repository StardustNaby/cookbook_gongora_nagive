import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/step.dart' as domain;
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
  final List<domain.Step> _steps = [];
  
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();
  
  final _stepDescriptionController = TextEditingController();

  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _loadRecipeData(widget.recipe!);
      _isDataLoaded = true;
    }
  }

  void _loadRecipeData(Recipe recipe) {
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description ?? '';
    _imageUrlController.text = recipe.imageUrl ?? '';
    _prepTimeController.text = recipe.prepTimeMinutes.toString();
    _difficulty = recipe.difficulty;
    _ingredients.clear();
    // Create new ingredient instances with correct recipe ID
    _ingredients.addAll(recipe.ingredients.map((ing) => Ingredient(
      id: ing.id,
      recipeId: recipe.id,
      name: ing.name,
      quantity: ing.quantity,
      unit: ing.unit,
    )));
    _steps.clear();
    // Create new step instances with correct recipe ID
    _steps.addAll(recipe.steps.map((step) => domain.Step(
      id: step.id,
      recipeId: recipe.id,
      stepNumber: step.stepNumber,
      description: step.description,
    )));
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

  void _addIngredient([Recipe? currentRecipe]) {
    if (_ingredientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa el nombre del ingrediente'),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }
    if (_ingredientQuantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa la cantidad'),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }
    if (_ingredientUnitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa la unidad'),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    final recipeId = currentRecipe?.id ?? 
                     widget.recipe?.id ?? 
                     widget.recipeId ?? 
                     '';

    setState(() {
      _ingredients.add(
        Ingredient(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          recipeId: recipeId,
          name: _ingredientNameController.text.trim(),
          quantity: double.tryParse(_ingredientQuantityController.text.trim()) ?? 0,
          unit: _ingredientUnitController.text.trim(),
        ),
      );
      _ingredientNameController.clear();
      _ingredientQuantityController.clear();
      _ingredientUnitController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep([Recipe? currentRecipe]) {
    if (_stepDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa la descripción del paso'),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    final recipeId = currentRecipe?.id ?? 
                     widget.recipe?.id ?? 
                     widget.recipeId ?? 
                     '';

    setState(() {
      _steps.add(
        domain.Step(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          recipeId: recipeId,
          stepNumber: _steps.length + 1,
          description: _stepDescriptionController.text.trim(),
        ),
      );
      _stepDescriptionController.clear();
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Reorder steps
      _reorderSteps();
    });
  }

  void _reorderSteps() {
    for (int i = 0; i < _steps.length; i++) {
      _steps[i] = domain.Step(
        id: _steps[i].id,
        recipeId: _steps[i].recipeId,
        stepNumber: i + 1,
        description: _steps[i].description,
      );
    }
  }

  void _onStepReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final step = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, step);
      _reorderSteps();
    });
  }

  Future<void> _saveRecipe([Recipe? currentRecipeParam]) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate ingredients and steps
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor agrega al menos un ingrediente'),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor agrega al menos un paso'),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final currentRecipe = currentRecipeParam ?? widget.recipe;
    final newRecipe = Recipe(
      id: currentRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty 
          ? null 
          : _imageUrlController.text.trim(),
      prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()) ?? 0,
      difficulty: _difficulty,
      isFavorite: currentRecipe?.isFavorite ?? false,
      createdAt: currentRecipe?.createdAt ?? now,
      updatedAt: now,
      ingredients: _ingredients,
      steps: _steps,
    );

    try {
      final notifier = ref.read(recipeNotifierProvider.notifier);
      
      if (currentRecipe == null) {
        await notifier.createRecipe(newRecipe);
      } else {
        await notifier.updateRecipe(newRecipe);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentRecipe == null 
                  ? 'Receta creada exitosamente' 
                  : 'Receta actualizada exitosamente',
            ),
            backgroundColor: const Color(0xFFFFB6C1),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade300,
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFFFFB6C1),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFFFFB6C1))
          : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFFFFB6C1),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFFFFB6C1),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFFFF91A4),
          width: 2.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.red.shade300,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.red.shade300,
          width: 2.5,
        ),
      ),
      errorStyle: GoogleFonts.poppins(
        color: Colors.red.shade300,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we have a recipeId but no recipe, load it
    if (widget.recipeId != null && widget.recipe == null) {
      final recipeAsync = ref.watch(recipeByIdProvider(widget.recipeId!));
      
      return recipeAsync.when(
        data: (recipe) {
          // Load recipe data if not already loaded
          if (!_isDataLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _loadRecipeData(recipe);
                  _isDataLoaded = true;
                });
              }
            });
          }
          return _buildForm(context, recipe, recipe);
        },
        loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFB6C1),
            ),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text(
              'Error: $error',
              style: GoogleFonts.poppins(),
            ),
          ),
        ),
      );
    }
    
    return _buildForm(context, widget.recipe, widget.recipe);
  }

  Widget _buildForm(BuildContext context, Recipe? recipe, [Recipe? currentRecipe]) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe == null ? 'Nueva Receta' : 'Editar Receta',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  'Nombre de la receta',
                  prefixIcon: Icons.restaurant_menu,
                ),
                style: GoogleFonts.poppins(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(
                  'Descripción',
                  prefixIcon: Icons.description,
                ),
                style: GoogleFonts.poppins(),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Image URL field
              TextFormField(
                controller: _imageUrlController,
                decoration: _buildInputDecoration(
                  'URL de la imagen',
                  prefixIcon: Icons.image,
                ),
                style: GoogleFonts.poppins(),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              // Prep time and difficulty row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: _buildInputDecoration(
                        'Tiempo (min)',
                        prefixIcon: Icons.timer,
                      ),
                      style: GoogleFonts.poppins(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Debe ser un número';
                        }
                        if (int.parse(value.trim()) <= 0) {
                          return 'Debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<Difficulty>(
                      value: _difficulty,
                      decoration: _buildInputDecoration('Dificultad'),
                      style: GoogleFonts.poppins(),
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    color: const Color(0xFFFF91A4),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ingredientes',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF91A4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ingredients list
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFFFE4E9),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFFFF91A4),
                      ),
                    ),
                    title: Text(
                      ingredient.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    subtitle: Text(
                      '${ingredient.quantity} ${ingredient.unit}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8B7355),
                        fontSize: 13,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => _removeIngredient(index),
                      tooltip: 'Eliminar',
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              // Add ingredient fields
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFFE4E9),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ingredientNameController,
                            decoration: _buildInputDecoration('Nombre'),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ingredientQuantityController,
                            decoration: _buildInputDecoration('Cantidad'),
                            style: GoogleFonts.poppins(fontSize: 14),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ingredientUnitController,
                            decoration: _buildInputDecoration('Unidad'),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _addIngredient(currentRecipe ?? recipe),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFFF69B4),
                      ),
                      label: Text(
                        'Agregar Ingrediente',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF69B4),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Steps section
              const SizedBox(height: 32),
              Row(
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    color: const Color(0xFFFF91A4),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pasos',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF91A4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Steps list with ReorderableListView
              if (_steps.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F0),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFFFE4E9),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'No hay pasos aún. Agrega el primero arriba.',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF8B7355),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _steps.length,
                  onReorder: _onStepReorder,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Container(
                      key: ValueKey(step.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFFFE4E9),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF91A4),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${step.stepNumber}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          step.description,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.drag_handle,
                              color: Color(0xFFFF91A4),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeStep(index),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              // Add step field
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFFE4E9),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _stepDescriptionController,
                      decoration: _buildInputDecoration('Descripción del paso'),
                      style: GoogleFonts.poppins(fontSize: 14),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _addStep(currentRecipe ?? recipe),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFFF69B4),
                      ),
                      label: Text(
                        'Agregar Paso',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF69B4),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Save button
              ElevatedButton(
                onPressed: () => _saveRecipe(currentRecipe ?? recipe),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC1CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  recipe == null ? 'Crear Receta' : 'Actualizar Receta',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
