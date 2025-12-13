import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

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

class RecipeSuggestionsPage extends StatelessWidget {
  final List<String> items;
  const RecipeSuggestionsPage({super.key, required this.items});

  List<Map<String, String>> get _recipes => [
        {
          'title': 'Bœuf sauté aux pâtes',
          'time': '14 min',
          'difficulty': 'Facile',
          'servings': '1 personne',
          'image':
              'https://images.unsplash.com/photo-1473093226795-af9932fe5856?auto=format&fit=crop&w=800&q=80',
        },
        {
          'title': 'Bœuf Bourguignon express',
          'time': '18 min',
          'difficulty': 'Moyen',
          'servings': '2 personnes',
          'image':
              'https://images.unsplash.com/photo-1432139555190-58524dae6a55?auto=format&fit=crop&w=800&q=80',
        },
        {
          'title': 'Tarte fine aux légumes rôtis',
          'time': '22 min',
          'difficulty': 'Facile',
          'servings': '2 personnes',
          'image':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
        },
        {
          'title': 'Bowl coloré au poulet croustillant',
          'time': '16 min',
          'difficulty': 'Intermédiaire',
          'servings': '1 personne',
          'image':
              'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=800&q=80',
        },
        {
          'title': 'Risotto crémeux aux champignons',
          'time': '20 min',
          'difficulty': 'Moyen',
          'servings': '2 personnes',
          'image':
              'https://images.unsplash.com/photo-1476127396010-4f6bbad00215?auto=format&fit=crop&w=800&q=80',
        },
        {
          'title': 'Salade tiède saumon & agrumes',
          'time': '12 min',
          'difficulty': 'Facile',
          'servings': '1 personne',
          'image':
              'https://images.unsplash.com/photo-1481391032119-d89fee407e44?auto=format&fit=crop&w=800&q=80',
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
                          'Basées sur ton frigo (${items.length} ingrédients)',
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailPage(
                                  title: recipe['title']!,
                                  time: recipe['time']!,
                                  difficulty: recipe['difficulty']!,
                                  match: 90 - (index * 4),
                                  servings: recipe['servings']!,
                                  imageUrl: recipe['image']!,
                                ),
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
            child: const _GlassDock(),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final Map<String, String> recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = recipe['image']!;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 340,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    alignment: Alignment.center,
                    child: const Icon(Icons.restaurant, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: -18,
              child: GlassContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                borderRadius: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoLine(Icons.access_time, recipe['time']!, theme),
                        _infoLine(Icons.person_outline, recipe['servings']!, theme),
                        Text(
                          recipe['difficulty']!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recipe['title']!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
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

class _GlassDock extends StatelessWidget {
  const _GlassDock();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Accueil', 'icon': Icons.home_rounded},
      {'label': 'Scanner', 'icon': Icons.qr_code_scanner_rounded},
      {'label': 'Favoris', 'icon': Icons.favorite_border},
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
            children: List.generate(items.length, (index) {
              final selected = index == 0;
              final data = items[index];
              return Expanded(
                child: _DockButton(
                  label: data['label'] as String,
                  icon: data['icon'] as IconData,
                  selected: selected,
                ),
              );
            }),
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
  });

  final String label;
  final IconData icon;
  final bool selected;

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
          onTap: () {},
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

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String time;
  final String difficulty;
  final String servings;
  final String imageUrl;
  final int match;

  const RecipeDetailPage({
    super.key,
    required this.title,
    required this.time,
    required this.difficulty,
    required this.match,
    required this.servings,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = [
      'Préchauffer et préparer les ingrédients frais.',
      'Cuire les éléments de base (pâtes/riz/légumes).',
      'Assembler et assaisonner progressivement.',
      'Finaliser avec toppings frais et herbes.',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  alignment: Alignment.center,
                  child: const Icon(Icons.restaurant, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _infoChip(Icons.access_time, time, theme),
                    _infoChip(Icons.person_outline, servings, theme),
                    _infoChip(Icons.local_fire_department, difficulty, theme),
                    _infoChip(Icons.star_rounded, 'Match $match%', theme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Étapes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
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
                    const SizedBox(width: 10),
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
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Commencer la recette',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
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
}
