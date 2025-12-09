import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

class CuisinePreferencesPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(Set<String>) onUpdate;
  final Set<String> initialValue;
  
  const CuisinePreferencesPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onUpdate,
    required this.initialValue,
  });

  @override
  State<CuisinePreferencesPage> createState() => _CuisinePreferencesPageState();
}

class _CuisinePreferencesPageState extends State<CuisinePreferencesPage> {
  late Set<String> _selectedCuisines;
  
  @override
  void initState() {
    super.initState();
    _selectedCuisines = Set.from(widget.initialValue);
  }
  
  final List<Map<String, String>> _cuisines = [
    {'name': 'Francais', 'icon': '\u{1F956}'},
    {'name': 'Italien', 'icon': '\u{1F35D}'},
    {'name': 'Asiatique', 'icon': '\u{1F962}'},
    {'name': 'Mediterraneen', 'icon': '\u{1F345}'},
    {'name': 'Espagnol', 'icon': '\u{1F958}'},
    {'name': 'Mexicain', 'icon': '\u{1F32E}'},
    {'name': 'Indien', 'icon': '\u{1F35B}'},
    {'name': 'Surprends-moi', 'icon': '\u{1F381}'},
  ];

  void _toggleCuisine(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine)) {
        _selectedCuisines.remove(cuisine);
      } else {
        _selectedCuisines.add(cuisine);
      }
    });
    widget.onUpdate(_selectedCuisines);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 28),
          
          // Title
          Text(
            'Tes cuisines\npréférées',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            'Choisis les styles de cuisine que tu aimes le plus.\nOn s’en inspirera !',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Cuisines grid - 2 columns
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.6,
              ),
              itemCount: _cuisines.length,
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                final isSelected = _selectedCuisines.contains(cuisine['name']);
                return GestureDetector(
                  onTap: () => _toggleCuisine(cuisine['name']!),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    borderRadius: 22,
                    backgroundOpacity: isSelected ? 0.5 : 0.26,
                    strokeOpacity: isSelected ? 0.32 : 0.18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cuisine['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            cuisine['name']!,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Next button
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 12),
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
