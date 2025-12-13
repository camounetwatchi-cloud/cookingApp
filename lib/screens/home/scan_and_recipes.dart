import 'dart:async';
import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

enum DockTab { home, scanner, favorites }

class ScanInProgressPage extends StatelessWidget {
  const ScanInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan en cours'),
      ),
      body: Center(
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 78,
                width: 78,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                  backgroundColor: Color(0x220088FF),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Analyse de ton frigo…',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'On identifie les aliments et\nprépare des idées de recettes.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeSuggestionsPage extends StatefulWidget {
  final List<String> items;
  final void Function(Map<String, dynamic> recipe) onToggleFavorite;
  final bool Function(Map<String, dynamic> recipe) isFavorite;
  final void Function(DockTab tab) onSelectTab;

  const RecipeSuggestionsPage({
    super.key,
    required this.items,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.onSelectTab,
  });

  @override
  State<RecipeSuggestionsPage> createState() => _RecipeSuggestionsPageState();
}

class _RecipeSuggestionsPageState extends State<RecipeSuggestionsPage> {
  List<Map<String, dynamic>> get _recipes => [
        {
          'title': 'Bœuf sauté aux pâtes',
          'time': '14 min',
          'difficulty': 'Facile',
          'servings': '1 personne',
          'image':
              'https://images.unsplash.com/photo-1484723091739-33f42a6e711c?auto=format&fit=crop&w=900&q=80',
          'ingredients': [
            {'name': 'Pâtes fraîches', 'quantity': '200 g'},
            {'name': 'Tomates pelées', 'quantity': '400 g'},
            {'name': 'Ail', 'quantity': '2 gousses'},
            {'name': 'Bœuf', 'quantity': '150 g'},
          ],
          'stepsDetailed': [
            {
              'title': 'Les pâtes',
              'description':
                  'Faites bouillir une grande casserole d’eau salée et cuisez les pâtes 10 min.',
              'durationLabel': '10 min',
              'durationMinutes': 10,
            },
            {
              'title': 'Le bœuf',
              'description': 'Cuire le bœuf en émincés 7 min puis ajouter l’ail.',
              'durationLabel': '7-8 min',
              'durationMinutes': 8,
            },
            {
              'title': 'Les tomates',
              'description': 'Ajoutez les tomates pelées et faites revenir à feu doux.',
              'durationLabel': '4 min',
              'durationMinutes': 4,
            },
            {
              'title': 'Dressage',
              'description': 'Servez avec un filet d’huile d’olive et du basilic.',
              'durationLabel': '1 min',
              'durationMinutes': 1,
            },
          ],
          'steps': [
            'Faites bouillir une grande casserole d’eau salée et cuisez les pâtes 10 min.',
            'Cuire le bœuf en émincés 7 min puis ajouter l’ail.',
            'Ajoutez les tomates pelées et faites revenir à feu doux.',
            'Servez avec un filet d’huile d’olive et du basilic.',
          ],
        },
        {
          'title': 'Bœuf Bourguignon express',
          'time': '18 min',
          'difficulty': 'Moyen',
          'servings': '2 personnes',
          'image':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
          'ingredients': [
            {'name': 'Bœuf', 'quantity': '300 g'},
            {'name': 'Carottes', 'quantity': '2 pièces'},
            {'name': 'Oignons', 'quantity': '1 pièce'},
            {'name': 'Vin rouge', 'quantity': '120 ml'},
          ],
          'stepsDetailed': [
            {
              'title': 'Le bœuf',
              'description': 'Saisir le bœuf puis ajouter les oignons.',
              'durationLabel': '6 min',
              'durationMinutes': 6,
            },
            {
              'title': 'Le vin rouge',
              'description': 'Déglacer avec le vin et ajouter les carottes.',
              'durationLabel': '4 min',
              'durationMinutes': 4,
            },
            {
              'title': 'Mijotage',
              'description': 'Laisser mijoter 12 minutes.',
              'durationLabel': '12 min',
              'durationMinutes': 12,
            },
            {
              'title': 'Dressage',
              'description': 'Servir avec un écrasé de pommes de terre.',
              'durationLabel': '2 min',
              'durationMinutes': 2,
            },
          ],
          'steps': [
            'Saisir le bœuf puis ajouter les oignons.',
            'Déglacer avec le vin et ajouter les carottes.',
            'Laisser mijoter 12 minutes.',
            'Servir avec un écrasé de pommes de terre.',
          ],
        },
        {
          'title': 'Tarte fine aux légumes rôtis',
          'time': '22 min',
          'difficulty': 'Facile',
          'servings': '2 personnes',
          'image':
              'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=900&q=80',
          'ingredients': [
            {'name': 'Pâte feuilletée', 'quantity': '1 disque'},
            {'name': 'Courgette', 'quantity': '1 pièce'},
            {'name': 'Tomates cerises', 'quantity': '6 pièces'},
            {'name': 'Feta', 'quantity': '80 g'},
          ],
          'stepsDetailed': [
            {
              'title': 'La pâte',
              'description': 'Précuire la pâte 5 minutes.',
              'durationLabel': '5 min',
              'durationMinutes': 5,
            },
            {
              'title': 'Les légumes',
              'description': 'Disposer les légumes et arroser d’huile.',
              'durationLabel': '5 min',
              'durationMinutes': 5,
            },
            {
              'title': 'Cuisson',
              'description': 'Cuire 15 minutes à 200°C.',
              'durationLabel': '15 min',
              'durationMinutes': 15,
            },
            {
              'title': 'Finitions',
              'description': 'Parsemer de feta et d’herbes fraîches.',
              'durationLabel': '2 min',
              'durationMinutes': 2,
            },
          ],
          'steps': [
            'Précuire la pâte 5 minutes.',
            'Disposer les légumes et arroser d’huile.',
            'Cuire 15 minutes à 200°C.',
            'Parsemer de feta et d’herbes fraîches.',
          ],
        },
        {
          'title': 'Bowl coloré au poulet croustillant',
          'time': '16 min',
          'difficulty': 'Intermédiaire',
          'servings': '1 personne',
          'image':
              'https://images.unsplash.com/photo-1478145046317-39f10e56b5e9?auto=format&fit=crop&w=900&q=80',
          'ingredients': [
            {'name': 'Poulet croustillant', 'quantity': '120 g'},
            {'name': 'Riz', 'quantity': '80 g'},
            {'name': 'Avocat', 'quantity': '1/2 pièce'},
            {'name': 'Chou rouge', 'quantity': '50 g'},
          ],
          'stepsDetailed': [
            {
              'title': 'Le riz',
              'description': 'Cuire le riz puis réserver.',
              'durationLabel': '10 min',
              'durationMinutes': 10,
            },
            {
              'title': 'Le poulet',
              'description': 'Saisir le poulet et le trancher.',
              'durationLabel': '6 min',
              'durationMinutes': 6,
            },
            {
              'title': 'Le bol',
              'description': 'Disposer tous les éléments dans un bol.',
              'durationLabel': '3 min',
              'durationMinutes': 3,
            },
            {
              'title': 'La sauce',
              'description': 'Ajouter une sauce soja-miel.',
              'durationLabel': '1 min',
              'durationMinutes': 1,
            },
          ],
          'steps': [
            'Cuire le riz puis réserver.',
            'Saisir le poulet et le trancher.',
            'Disposer tous les éléments dans un bol.',
            'Ajouter une sauce soja-miel.',
          ],
        },
        {
          'title': 'Risotto crémeux aux champignons',
          'time': '20 min',
          'difficulty': 'Moyen',
          'servings': '2 personnes',
          'image':
              'https://images.unsplash.com/photo-1481070414801-51fd732d7184?auto=format&fit=crop&w=900&q=80',
          'ingredients': [
            {'name': 'Riz arborio', 'quantity': '180 g'},
            {'name': 'Champignons', 'quantity': '200 g'},
            {'name': 'Parmesan', 'quantity': '50 g'},
            {'name': 'Bouillon', 'quantity': '500 ml'},
          ],
          'stepsDetailed': [
            {
              'title': 'Les champignons',
              'description': 'Faire revenir les champignons.',
              'durationLabel': '5 min',
              'durationMinutes': 5,
            },
            {
              'title': 'Le riz',
              'description': 'Ajouter le riz et mouiller progressivement.',
              'durationLabel': '4 min',
              'durationMinutes': 4,
            },
            {
              'title': 'Cuisson',
              'description': 'Remuer 15 minutes jusqu’à absorption.',
              'durationLabel': '15 min',
              'durationMinutes': 15,
            },
            {
              'title': 'Finitions',
              'description': 'Terminer au parmesan et beurre.',
              'durationLabel': '2 min',
              'durationMinutes': 2,
            },
          ],
          'steps': [
            'Faire revenir les champignons.',
            'Ajouter le riz et mouiller progressivement.',
            'Remuer 15 minutes jusqu’à absorption.',
            'Terminer au parmesan et beurre.',
          ],
        },
        {
          'title': 'Salade tiède saumon & agrumes',
          'time': '12 min',
          'difficulty': 'Facile',
          'servings': '1 personne',
          'image':
              'https://images.unsplash.com/photo-1506086679524-493c64fdfaa6?auto=format&fit=crop&w=900&q=80',
          'ingredients': [
            {'name': 'Saumon', 'quantity': '120 g'},
            {'name': 'Orange', 'quantity': '1/2 pièce'},
            {'name': 'Pamplemousse', 'quantity': '1/2 pièce'},
            {'name': 'Roquette', 'quantity': '40 g'},
          ],
          'stepsDetailed': [
            {
              'title': 'Le saumon',
              'description': 'Poêler rapidement le saumon.',
              'durationLabel': '6 min',
              'durationMinutes': 6,
            },
            {
              'title': 'Les agrumes',
              'description': 'Préparer les suprêmes d’agrumes.',
              'durationLabel': '4 min',
              'durationMinutes': 4,
            },
            {
              'title': 'La roquette',
              'description': 'Mélanger à la roquette avec une vinaigrette.',
              'durationLabel': '2 min',
              'durationMinutes': 2,
            },
            {
              'title': 'Graines',
              'description': 'Ajouter des graines de sésame.',
              'durationLabel': '1 min',
              'durationMinutes': 1,
            },
          ],
          'steps': [
            'Poêler rapidement le saumon.',
            'Préparer les suprêmes d’agrumes.',
            'Mélanger à la roquette avec une vinaigrette.',
            'Ajouter des graines de sésame.',
          ],
        },
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipes = _recipes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Idées de recettes',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Basées sur ton frigo (${widget.items.length} ingrédients)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0)
                        .copyWith(bottom: 180),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = recipes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == recipes.length - 1 ? 0 : 28),
                        child: _RecipeCard(
                          recipe: recipe,
                          isFavorite: widget.isFavorite(recipe),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => RecipeDetailSheet(
                                recipe: recipe,
                                matchScore: 90 - (index * 4),
                                isFavorite: widget.isFavorite(recipe),
                                onToggleFavorite: () {
                                  widget.onToggleFavorite(recipe);
                                  setState(() {});
                                },
                                onSelectTab: widget.onSelectTab,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: recipes.length,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassDock(
              selectedTab: DockTab.home,
              onTap: widget.onSelectTab,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.isFavorite,
  });

  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = recipe['image'] as String;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 340,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _DishPlateImage(imageUrl: image, size: 260),
            Positioned(
              top: 24,
              right: 36,
              child: GlassContainer(
                padding: const EdgeInsets.all(10),
                borderRadius: 24,
                backgroundOpacity: 0.4,
                strokeOpacity: 0.2,
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : AppColors.primaryBlue,
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              child: SizedBox(
                width: 240,
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  borderRadius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _infoLine(Icons.access_time, recipe['time'] as String, theme),
                          _infoLine(Icons.person_outline, recipe['servings'] as String, theme),
                          _infoLine(Icons.local_fire_department, recipe['difficulty'] as String, theme),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        recipe['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class FavoriteRecipesPage extends StatefulWidget {
  const FavoriteRecipesPage({
    super.key,
    required this.recipes,
    required this.onToggleFavorite,
    required this.onSelectTab,
    required this.isFavorite,
  });

  final List<Map<String, dynamic>> recipes;
  final void Function(Map<String, dynamic> recipe) onToggleFavorite;
  final bool Function(Map<String, dynamic> recipe) isFavorite;
  final void Function(DockTab tab) onSelectTab;

  @override
  State<FavoriteRecipesPage> createState() => _FavoriteRecipesPageState();
}

class _FavoriteRecipesPageState extends State<FavoriteRecipesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipes = widget.recipes;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes favoris',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Recettes enregistrées pour plus tard.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (recipes.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Ajoute une recette depuis les suggestions.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 140),
                        itemCount: recipes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return _RecipeCard(
                            recipe: recipe,
                            isFavorite: widget.isFavorite(recipe),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => RecipeDetailSheet(
                                  recipe: recipe,
                                  matchScore: 95,
                                  isFavorite: widget.isFavorite(recipe),
                                  onToggleFavorite: () {
                                    widget.onToggleFavorite(recipe);
                                    setState(() {});
                                  },
                                  onSelectTab: widget.onSelectTab,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassDock(
              selectedTab: DockTab.favorites,
              onTap: widget.onSelectTab,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassDock extends StatelessWidget {
  const _GlassDock({
    required this.selectedTab,
    required this.onTap,
  });

  final DockTab selectedTab;
  final void Function(DockTab tab) onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Accueil', 'icon': Icons.home_rounded, 'tab': DockTab.home},
      {
        'label': 'Scanner',
        'icon': Icons.qr_code_scanner_rounded,
        'tab': DockTab.scanner
      },
      {'label': 'Favoris', 'icon': Icons.favorite_border, 'tab': DockTab.favorites},
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          borderRadius: 40,
          backgroundOpacity: 0.5,
          strokeOpacity: 0.22,
          child: Row(
            children: items.map((data) {
              final tab = data['tab'] as DockTab;
              final selected = tab == selectedTab;
              return Expanded(
                child: _DockButton(
                  label: data['label'] as String,
                  icon: data['icon'] as IconData,
                  selected: selected,
                  onTap: () => onTap(tab),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: selected
            ? LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.95),
                  AppColors.primaryBlue,
                ],
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DishPlateImage extends StatelessWidget {
  const _DishPlateImage({
    required this.imageUrl,
    required this.size,
  });

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            Colors.white,
            const Color(0xFFEFF5FF),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipOval(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.1),
              BlendMode.screen,
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryBlue.withOpacity(0.08),
                alignment: Alignment.center,
                child: const Icon(Icons.restaurant, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeDetailSheet extends StatefulWidget {
  const RecipeDetailSheet({
    super.key,
    required this.recipe,
    required this.matchScore,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onSelectTab,
  });

  final Map<String, dynamic> recipe;
  final int matchScore;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final void Function(DockTab tab)? onSelectTab;

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  int _portions = 1;
  late final List<_IngredientInfo> _ingredients;
  late final List<String> _steps;
  late final List<_StepDetail> _stepDetails;
  final Set<int> _checked = {};
  late bool _isFavorite;
  static const Map<String, String> _ingredientEmojis = {
    'pâtes': '🍝',
    'pate': '🍝',
    'tomate': '🍅',
    'ail': '🧄',
    'bœuf': '🥩',
    'boeuf': '🥩',
    'carotte': '🥕',
    'oignon': '🧅',
    'vin': '🍷',
    'courgette': '🥒',
    'feta': '🧀',
    'poulet': '🍗',
    'riz': '🍚',
    'avocat': '🥑',
    'chou': '🥬',
    'champignon': '🍄',
    'parmesan': '🧀',
    'saumon': '🐟',
    'orange': '🍊',
    'pamplemousse': '🍊',
    'roquette': '🌿',
    'bouillon': '🥣',
    'lait': '🥛',
    'œuf': '🥚',
    'oeuf': '🥚',
  };

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _ingredients = (widget.recipe['ingredients'] as List)
        .map((item) => _IngredientInfo.fromMap(item as Map))
        .toList();
    final detailed = widget.recipe['stepsDetailed'] as List?;
    if (detailed != null && detailed.isNotEmpty) {
      _stepDetails = detailed
          .map((data) => _StepDetail.fromMap(data as Map<String, dynamic>))
          .toList();
      _steps = _stepDetails.map((e) => e.description).toList();
    } else {
      final rawSteps = List<String>.from(widget.recipe['steps'] as List);
      _stepDetails = rawSteps
          .asMap()
          .entries
          .map(
            (entry) => _StepDetail(
              title: 'Étape ${entry.key + 1}',
              description: entry.value,
              durationLabel: null,
              durationMinutes: null,
            ),
          )
          .toList();
      _steps = rawSteps;
    }
  }

  String _emojiForIngredient(String name) {
    final lower = name.toLowerCase();
    for (final entry in _ingredientEmojis.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return '🍽️';
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onToggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.recipe['image'] as String;
    final title = widget.recipe['title'] as String;
    final time = widget.recipe['time'] as String;
    final difficulty = widget.recipe['difficulty'] as String;
    final servings = widget.recipe['servings'] as String;

    return FractionallySizedBox(
      heightFactor: 0.96,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      24 + MediaQuery.of(context).viewPadding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                            GlassContainer(
                              padding: const EdgeInsets.all(10),
                              borderRadius: 20,
                              backgroundOpacity: 0.28,
                              strokeOpacity: 0.2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _toggleFavorite,
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _isFavorite
                                      ? Colors.redAccent
                                      : AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: SizedBox(
                            height: 380,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                _DishPlateImage(imageUrl: imageUrl, size: 280),
                                Positioned(
                                  top: 210,
                                  child: SizedBox(
                                    width: 260,
                                    child: GlassContainer(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      borderRadius: 28,
                                      backgroundOpacity: 0.45,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Prête en $time avec ce que tu as sous la main.',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: AppColors.textMuted,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 8,
                                            children: [
                                              _infoChip(Icons.access_time, time, theme),
                                              _infoChip(Icons.person_outline, _servingsLabel, theme),
                                              _infoChip(
                                                Icons.local_fire_department,
                                                difficulty,
                                                theme,
                                              ),
                                              _infoChip(
                                                Icons.star_rounded,
                                                'Match ${widget.matchScore}%',
                                                theme,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$_portions Portion${_portions > 1 ? 's' : ''}',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  _portionButton(Icons.remove, () {
                                                    if (_portions > 1) {
                                                      setState(() => _portions--);
                                                    }
                                                  }),
                                                  const SizedBox(width: 8),
                                                  _portionButton(Icons.add, () {
                                                    setState(() => _portions++);
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 56),
                        Text(
                          'Ingrédients',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._ingredients.asMap().entries.map((entry) {
                          final index = entry.key;
                        final ingredient = entry.value;
                        final checked = _checked.contains(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              borderRadius: 24,
                              backgroundOpacity: 0.32,
                              strokeOpacity: 0.2,
                              child: Row(
                                children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (checked) {
                                        _checked.remove(index);
                                      } else {
                                        _checked.add(index);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    checked
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: checked
                                        ? AppColors.primaryBlue
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GlassContainer(
                                  padding: const EdgeInsets.all(9),
                                  borderRadius: 16,
                                  backgroundOpacity: 0.3,
                                  strokeOpacity: 0.18,
                                  child: Text(
                                    _emojiForIngredient(ingredient.name),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  ingredient.quantityFor(_portions),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Text(
                          'Préparation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._steps.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final step = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(14),
                              borderRadius: 20,
                              backgroundOpacity: 0.24,
                              strokeOpacity: 0.18,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GlassContainer(
                                    padding: const EdgeInsets.all(8),
                                    borderRadius: 12,
                                    backgroundOpacity: 0.32,
                                    strokeOpacity: 0.2,
                                    child: Text(
                                      '$idx',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 18),
                      LiquidGlassButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StepByStepPage(
                                steps: _stepDetails,
                                recipeTitle: title,
                                imageUrl: imageUrl,
                                onSelectTab: widget.onSelectTab,
                              ),
                            ),
                          );
                        },
                          height: 56,
                          width: double.infinity,
                          isBlue: true,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Commencer la recette',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        LiquidGlassButton(
                          onPressed: _toggleFavorite,
                          height: 56,
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite
                                    ? Colors.redAccent
                                    : AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isFavorite
                                    ? 'Retirer des favoris'
                                    : 'Ajouter aux favoris',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portionButton(IconData icon, VoidCallback onPressed) {
    return GlassContainer(
      padding: const EdgeInsets.all(8),
      borderRadius: 20,
      backgroundOpacity: 0.24,
      strokeOpacity: 0.18,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 16,
      backgroundOpacity: 0.22,
      strokeOpacity: 0.18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _servingsLabel =>
      _portions > 1 ? '$_portions personnes' : '1 personne';
}

class StepByStepPage extends StatefulWidget {
  const StepByStepPage({
    super.key,
    required this.steps,
    required this.recipeTitle,
    required this.imageUrl,
    this.onSelectTab,
  });

  final List<_StepDetail> steps;
  final String recipeTitle;
  final String imageUrl;
  final void Function(DockTab tab)? onSelectTab;

  @override
  State<StepByStepPage> createState() => _StepByStepPageState();
}

class _StepByStepPageState extends State<StepByStepPage> {
  final PageController _controller = PageController();
  final List<_ActiveTimer> _timers = [];
  Timer? _ticker;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timers.removeWhere((timer) => timer.remaining <= Duration.zero);
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer(_StepDetail step) {
    if (step.durationMinutes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pas de durée pour cette étape.')),
      );
      return;
    }
    setState(() {
      _timers.add(
        _ActiveTimer(
          label: step.title,
          duration: Duration(minutes: step.durationMinutes!),
        ),
      );
    });
  }

  void _goToCompletion(BuildContext context) {
    _ticker?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecipeCompletionPage(
          imageUrl: widget.imageUrl,
          onSelectTab: widget.onSelectTab,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.recipeTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_timers.isNotEmpty && _currentIndex < widget.steps.length)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timers
                      .map(
                        (timer) => GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          borderRadius: 20,
                          backgroundOpacity: 0.35,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 6),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Encore ',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                    TextSpan(
                                      text: _formatDuration(timer.remaining),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' pour ${timer.label}',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _timers.remove(timer);
                                  });
                                },
                                child: const Icon(Icons.close_rounded, size: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: widget.steps.length,
                itemBuilder: (context, index) {
                  final step = widget.steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 24,
                          backgroundOpacity: 0.35,
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          borderRadius: 32,
                          backgroundOpacity: 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                step.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (step.durationLabel != null)
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 18, color: AppColors.primaryBlue),
                                    const SizedBox(width: 6),
                                    Text(
                                      step.durationLabel!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        LiquidGlassButton(
                          onPressed: () => _startTimer(step),
                          height: 56,
                          width: double.infinity,
                          isBlue: true,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Lancer un timer pour vous aider ?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Opacity(
                                opacity: index == 0 ? 0.4 : 1,
                                child: LiquidGlassButton(
                                  onPressed: index == 0
                                      ? null
                                      : () => _controller.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut,
                                          ),
                                  height: 52,
                                  width: double.infinity,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_back_ios_new_rounded,
                                          size: 18, color: AppColors.primaryBlue),
                                      SizedBox(width: 6),
                                      Text(
                                        'Étape précédente',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Opacity(
                                opacity: index == widget.steps.length - 1 ? 0.4 : 1,
                                child: LiquidGlassButton(
                                  onPressed: index == widget.steps.length - 1
                                      ? null
                                      : () => _controller.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut,
                                          ),
                                  height: 52,
                                  width: double.infinity,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Étape suivante',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          size: 18, color: AppColors.primaryBlue),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (index == widget.steps.length - 1) ...[
                          const SizedBox(height: 16),
                          LiquidGlassButton(
                            onPressed: () => _goToCompletion(context),
                            height: 56,
                            width: double.infinity,
                            isBlue: true,
                            child: const Text(
                              'Finir la recette',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                'Étape ${_currentIndex + 1} / ${widget.steps.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final remaining = duration.isNegative ? Duration.zero : duration;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    if (minutes > 0) {
      return seconds > 0 ? '$minutes min ${seconds.toString().padLeft(2, '0')} s' : '$minutes min';
    }
    return '${seconds}s';
  }

}

class _ActiveTimer {
  _ActiveTimer({required this.label, required this.duration})
      : _start = DateTime.now();

  final String label;
  final Duration duration;
  final DateTime _start;

  Duration get remaining {
    final elapsed = DateTime.now().difference(_start);
    return duration - elapsed;
  }
}

class RecipeCompletionPage extends StatelessWidget {
  const RecipeCompletionPage({
    super.key,
    required this.imageUrl,
    this.onSelectTab,
  });

  final String imageUrl;
  final void Function(DockTab tab)? onSelectTab;

  void _handleTap(BuildContext context, DockTab tab) {
    if (onSelectTab != null) {
      onSelectTab!(tab);
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DishPlateImage(imageUrl: imageUrl, size: 270),
                        const SizedBox(height: 32),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 28,
                          ),
                          borderRadius: 32,
                          child: Column(
                            children: [
                              Text(
                                'C’est prêt !',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Régalez-vous et bravo d’avoir participé à l’antigaspi !',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassDock(
              selectedTab: DockTab.home,
              onTap: (tab) => _handleTap(context, tab),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientInfo {
  const _IngredientInfo({
    required this.name,
    required this.originalQuantity,
    this.baseValue,
    this.unit = '',
  });

  final String name;
  final String originalQuantity;
  final double? baseValue;
  final String unit;

  factory _IngredientInfo.fromMap(Map data) {
    final name = data['name']?.toString() ?? '';
    final quantity = data['quantity']?.toString() ?? '';
    final match = RegExp(r'([0-9]+(?:[.,][0-9]+)?(?:\s*/\s*[0-9]+)?)\s*(.*)')
        .firstMatch(quantity);
    double? value;
    String unit = '';
    if (match != null) {
      final rawValue = match.group(1)!.trim();
      if (rawValue.contains('/')) {
        final fraction = rawValue.split('/');
        final num = double.tryParse(fraction[0].trim());
        final den = double.tryParse(fraction[1].trim());
        if (num != null && den != null && den != 0) {
          value = num / den;
        }
      } else {
        value = double.tryParse(rawValue.replaceAll(',', '.'));
      }
      unit = match.group(2)?.trim() ?? '';
    }
    return _IngredientInfo(
      name: name,
      originalQuantity: quantity,
      baseValue: value,
      unit: unit,
    );
  }

  String quantityFor(int portions) {
    if (baseValue == null) return originalQuantity;
    final scaled = baseValue! * portions;
    final isInt = scaled % 1 == 0;
    final valueStr = isInt
        ? scaled.toInt().toString()
        : scaled.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    if (unit.isEmpty) return valueStr;
    return '$valueStr $unit';
  }
}

class _StepDetail {
  const _StepDetail({
    required this.title,
    required this.description,
    this.durationLabel,
    this.durationMinutes,
  });

  final String title;
  final String description;
  final String? durationLabel;
  final int? durationMinutes;

  factory _StepDetail.fromMap(Map<String, dynamic> map) {
    return _StepDetail(
      title: map['title']?.toString() ?? 'Étape',
      description: map['description']?.toString() ?? '',
      durationLabel: map['durationLabel']?.toString(),
      durationMinutes: map['durationMinutes'] is int
          ? map['durationMinutes'] as int
          : int.tryParse(map['durationMinutes']?.toString() ?? ''),
    );
  }
}
