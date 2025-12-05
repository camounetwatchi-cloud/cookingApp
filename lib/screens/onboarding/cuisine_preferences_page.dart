import 'package:flutter/material.dart';

class CuisinePreferencesPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const CuisinePreferencesPage({super.key, required this.onNext, required this.onBack});

  @override
  State<CuisinePreferencesPage> createState() => _CuisinePreferencesPageState();
}

class _CuisinePreferencesPageState extends State<CuisinePreferencesPage> {
  final Set<String> _selectedCuisines = {};
  
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
            'Tes cuisines\npreferees',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            'Choisis les styles de cuisine que tu aimes le plus.\nOn s\'en inspirera !',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Cuisines grid - 2 columns
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.8,
              ),
              itemCount: _cuisines.length,
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                final isSelected = _selectedCuisines.contains(cuisine['name']);
                return GestureDetector(
                  onTap: () => _toggleCuisine(cuisine['name']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4A9FFF) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF4A9FFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cuisine['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cuisine['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
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
