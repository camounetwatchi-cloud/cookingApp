import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          
          // Title
          const Text(
            'Tes allergies\nalimentaires',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            'Selectionnes les aliments auxquels tu es allergique.\nOn les prendra en compte dans nos recettes.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
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
                return GestureDetector(
                  onTap: () => _toggleAllergy(allergy['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF4A9FFF) 
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Next button - Blue rounded with play icon
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9FFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
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
