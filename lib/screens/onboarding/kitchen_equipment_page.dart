import 'package:flutter/material.dart';

class KitchenEquipmentPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(Set<String>) onUpdate;
  final Set<String> initialValue;
  
  const KitchenEquipmentPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onUpdate,
    required this.initialValue,
  });

  @override
  State<KitchenEquipmentPage> createState() => _KitchenEquipmentPageState();
}

class _KitchenEquipmentPageState extends State<KitchenEquipmentPage> {
  late Set<String> _selectedEquipment;
  
  @override
  void initState() {
    super.initState();
    _selectedEquipment = Set.from(widget.initialValue);
  }
  
  final List<Map<String, String>> _equipment = [
    {'name': 'Four', 'icon': '\u{1F525}'},
    {'name': 'Micro-ondes', 'icon': '\u{1F4E1}'},
    {'name': 'Plaques de cuisson', 'icon': '\u{1F373}'},
    {'name': 'Mixeur', 'icon': '\u{1F300}'},
    {'name': 'Poele', 'icon': '\u{1F373}'},
    {'name': 'Robot de cuisine', 'icon': '\u{1F916}'},
  ];

  void _toggleEquipment(String item) {
    setState(() {
      if (_selectedEquipment.contains(item)) {
        _selectedEquipment.remove(item);
      } else {
        _selectedEquipment.add(item);
      }
    });
    widget.onUpdate(_selectedEquipment);
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
            'Ton equipement\nde cuisine',
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
            'On evitera de te proposer une\nrecette au for si tu n\'en as pas !',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Equipment list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _equipment.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _equipment[index];
                final isSelected = _selectedEquipment.contains(item['name']);
                return GestureDetector(
                  onTap: () => _toggleEquipment(item['name']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      children: [
                        Text(
                          item['icon']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
