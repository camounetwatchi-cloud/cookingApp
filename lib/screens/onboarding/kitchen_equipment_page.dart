import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 28),
          
          // Title
          Text(
            'Ton équipement\nde cuisine',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            "On évitera de te proposer une\nrecette au four si tu n'en as pas !",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Equipment list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _equipment.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _equipment[index];
                final isSelected = _selectedEquipment.contains(item['name']);
                return SelectableGlassButton(
                  isSelected: isSelected,
                  onTap: () => _toggleEquipment(item['name']!),
                  child: Row(
                    children: [
                      Text(
                        item['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['name']!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Next button
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            child: SizedBox(
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LiquidGlassButton(
                      onPressed: widget.onBack,
                      height: 44,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Retour',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
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
            ),
          ),
        ],
      ),
    );
  }
}
