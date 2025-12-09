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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock recipes based on available items
    final recipes = [
      {
        'title': 'Pâtes crémeuses au saumon',
        'time': '20 min',
        'difficulty': 'Facile',
        'match': 92,
      },
      {
        'title': 'Bowl poulet croquant & avocat',
        'time': '18 min',
        'difficulty': 'Intermédiaire',
        'match': 88,
      },
      {
        'title': 'Wok de légumes gingembre',
        'time': '15 min',
        'difficulty': 'Rapide',
        'match': 84,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recettes proposées'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final match = recipe['match'] as int;
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecipeDetailPage(
                    title: recipe['title'] as String,
                    time: recipe['time'] as String,
                    difficulty: recipe['difficulty'] as String,
                    match: match,
                  ),
                ),
              );
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.restaurant, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _pill('${recipe['time']}', theme),
                            const SizedBox(width: 8),
                            _pill('${recipe['difficulty']}', theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 14,
                    backgroundOpacity: 0.22,
                    strokeOpacity: 0.2,
                    child: Text(
                      '$match%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _pill(String text, ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 12,
      backgroundOpacity: 0.22,
      strokeOpacity: 0.18,
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String time;
  final String difficulty;
  final int match;

  const RecipeDetailPage({
    super.key,
    required this.title,
    required this.time,
    required this.difficulty,
    required this.match,
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
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _pill('$time • $difficulty', theme),
                    const SizedBox(width: 8),
                    _pill('Match $match%', theme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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

  Widget _pill(String text, ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 12,
      backgroundOpacity: 0.22,
      strokeOpacity: 0.18,
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

