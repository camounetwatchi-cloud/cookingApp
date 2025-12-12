import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

class AllergiesPage extends StatefulWidget {
  final VoidCallback onNext;
  final Function(Set<String>) onUpdate;
  final Set<String> initialValue;
  
  const AllergiesPage({
    super.key,
    required this.onNext,
    required this.onUpdate,
    required this.initialValue,
  });

  @override
  State<AllergiesPage> createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage> {
  late Set<String> _selectedAllergies;
  
  @override
  void initState() {
    super.initState();
    _selectedAllergies = Set.from(widget.initialValue);
  }
  
  final List<Map<String, dynamic>> _allergies = [
    {'name': 'Gluten', 'icon': '🌾'},
    {'name': 'Lactose', 'icon': '🥛'},
    {'name': 'Fruits de mer', 'icon': '🦐'},
    {'name': 'Arachides', 'icon': '🥜'},
    {'name': 'Fruits à coque', 'icon': '🌰'},
    {'name': 'Œufs', 'icon': '🥚'},
    {'name': 'Soja', 'icon': '🫘'},
    {'name': 'Poisson', 'icon': '🐟'},
    {'name': 'Sésame', 'icon': '🫓'},
    {'name': 'Moutarde', 'icon': '🟡'},
    {'name': 'Céleri', 'icon': '🥬'},
    {'name': 'Sulfites', 'icon': '🍷'},
  ];

  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
    widget.onUpdate(_selectedAllergies);
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
            'Tes allergies\nalimentaires',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 10),
          
          // Subtitle
          Text(
            'Selectionne les aliments auxquels tu es allergique.\nOn les prendra en compte dans nos recettes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 22),
          
          // Allergy grid - 3 columns
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemCount: _allergies.length,
              itemBuilder: (context, index) {
                final allergy = _allergies[index];
                final isSelected = _selectedAllergies.contains(allergy['name']);
                return SelectableGlassButton(
                  isSelected: isSelected,
                  onTap: () => _toggleAllergy(allergy['name']),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        allergy['icon'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          allergy['name'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Next button - uses theme primary
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
              child: LiquidGlassButton(
              onPressed: widget.onNext,
              height: 64,
              isBlue: true,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
