import 'dart:ui';

import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

class DislikesPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(int) onUpdateSpice;
  final Function(Set<String>) onUpdateDislikes;
  final int initialSpiceLevel;
  final Set<String> initialDislikedItems;
  
  const DislikesPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onUpdateSpice,
    required this.onUpdateDislikes,
    required this.initialSpiceLevel,
    required this.initialDislikedItems,
  });

  @override
  State<DislikesPage> createState() => _DislikesPageState();
}

class _DislikesPageState extends State<DislikesPage> {
  late int _spiceLevel;
  late Set<String> _dislikedItems;
  late TextEditingController _searchController;
  
  final List<String> _spiceLevels = ['Pas epice', 'Un peu epice', 'Tres epice'];

  @override
  void initState() {
    super.initState();
    _spiceLevel = widget.initialSpiceLevel;
    _dislikedItems = Set.from(widget.initialDislikedItems);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addDislike(String item) {
    if (item.isNotEmpty && !_dislikedItems.contains(item)) {
      setState(() {
        _dislikedItems.add(item);
        _searchController.clear();
      });
      widget.onUpdateDislikes(_dislikedItems);
    }
  }

  void _removeDislike(String item) {
    setState(() {
      _dislikedItems.remove(item);
    });
    widget.onUpdateDislikes(_dislikedItems);
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
          Text(
            "Dernière étape !\nCe que tu n'aimes pas",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'On personnalisera tes recettes\nselon tes goûts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(3, (index) {
              final isSelected = _spiceLevel == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == 2 ? 0 : 6,
                  ),
                  child: SelectableGlassButton(
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _spiceLevel = index;
                      });
                      widget.onUpdateSpice(_spiceLevel);
                    },
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _spiceLevels[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryBlue.withOpacity(0.14),
              inactiveTrackColor: AppColors.textMuted.withOpacity(0.12),
              trackHeight: 6,
              thumbColor: Colors.white,
              thumbShape: const CustomThumbShape(),
              overlayColor: AppColors.primaryBlue.withOpacity(0.16),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _spiceLevel.toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() {
                  _spiceLevel = value.round();
                });
                widget.onUpdateSpice(_spiceLevel);
              },
            ),
          ),
          const Spacer(),
          Text(
            'Si tu veux indique simplement ce\nque tu n’aimes pas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderRadius: 18,
            backgroundOpacity: 0.28,
            strokeOpacity: 0.2,
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Ajoute un ingrédient',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: _addDislike,
                  ),
                ),
                Icon(Icons.mic, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
          if (_dislikedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dislikedItems.map((item) {
                  return GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: 16,
                    backgroundOpacity: 0.22,
                    strokeOpacity: 0.18,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item, style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeDislike(item),
                          child: Icon(Icons.close, size: 16, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
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

class CustomThumbShape extends SliderComponentShape {
  const CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final borderPaint = Paint()
      ..color = const Color(0xFF4A9FFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center + const Offset(0, 2), 12, shadowPaint);
    canvas.drawCircle(center, 12, fillPaint);
    canvas.drawCircle(center, 12, borderPaint);
  }
}
