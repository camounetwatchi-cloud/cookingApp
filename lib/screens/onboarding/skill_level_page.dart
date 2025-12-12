import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

class SkillLevelPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(int) onUpdate;
  final int initialValue;
  
  const SkillLevelPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onUpdate,
    required this.initialValue,
  });

  @override
  State<SkillLevelPage> createState() => _SkillLevelPageState();
}

class _SkillLevelPageState extends State<SkillLevelPage> {
  late int _selectedLevel;
  
  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialValue;
  }
  
  final List<String> _levelNames = ['Debutant', 'Intermediaire', 'Avance'];
  
  final List<String> _levelDescriptions = [
    'Je debute et cherche des recettes simples',
    'Je me debrouille bien et suis pret pour des recettes variees',
    'Je maitrise les techniques et veux des defis',
  ];

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
            'Ton niveau en\ncuisine',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'On adaptera les recettes à ton expérience',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          Row(
            children: List.generate(3, (index) {
              final isSelected = _selectedLevel == index;
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
                        _selectedLevel = index;
                      });
                      widget.onUpdate(_selectedLevel);
                    },
                    // Use same internal padding & text weight as allergies buttons
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      _levelNames[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
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
              value: _selectedLevel.toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              activeColor: AppColors.primaryBlue,
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value.round();
                });
                widget.onUpdate(_selectedLevel);
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _levelDescriptions[_selectedLevel],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
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
