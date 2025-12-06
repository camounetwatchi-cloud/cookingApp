import 'package:flutter/material.dart';

class PantryBasicsPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(Set<String>) onUpdate;
  final Set<String> initialValue;
  
  const PantryBasicsPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onUpdate,
    required this.initialValue,
  });

  @override
  State<PantryBasicsPage> createState() => _PantryBasicsPageState();
}

class _PantryBasicsPageState extends State<PantryBasicsPage> {
  late Set<String> _selectedItems;
  
  @override
  void initState() {
    super.initState();
    _selectedItems = Set.from(widget.initialValue);
  }
  
  final Map<String, List<String>> _categories = {
    'CONDIMENTS': ['Sel', 'Poivre', 'Vinaigre'],
    'HUILES': ['Huile d\'olive', 'Huile de sesame', 'Huile neutre'],
    'FECULENTS': ['Pates', 'Riz', 'Semoule', 'Quinoa', 'Lentilles'],
  };

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
    widget.onUpdate(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Title
          const Center(
            child: Text(
              'Tes basiques\ndu placard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Center(
            child: Text(
              'Coches ce que tu as presque toujours chez toi.\nOn les utilisera dans les recettes',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Scrollable content with categories
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categories.entries.map((entry) {
                  return _buildCategory(entry.key, entry.value);
                }).toList(),
              ),
            ),
          ),
          
          // Next button
          Center(
            child: Padding(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Items wrap
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final isSelected = _selectedItems.contains(item);
            return GestureDetector(
              onTap: () => _toggleItem(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4A9FFF) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
}
