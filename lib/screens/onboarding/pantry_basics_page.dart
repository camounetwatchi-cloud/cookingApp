import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          
          // Title
          Center(
            child: Text(
              'Tes basiques\ndu placard',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Center(
            child: Text(
              'Coche ce que tu as presque toujours chez toi.\nOn les utilisera dans les recettes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryBlue,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Scrollable content with categories
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categories.entries.map((entry) {
                  return _buildCategory(entry.key, entry.value, theme);
                }).toList(),
              ),
            ),
          ),
          
          // Next button
          Center(
            child: Padding(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<String> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ),
        
        // Items wrap
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final isSelected = _selectedItems.contains(item);
            return SelectableGlassButton(
              isSelected: isSelected,
              onTap: () => _toggleItem(item),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              borderRadius: 18,
              child: Text(
                item,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
