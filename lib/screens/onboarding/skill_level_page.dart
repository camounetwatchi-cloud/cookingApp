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
  late double _sliderValue;
  
  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialValue;
    _sliderValue = _selectedLevel.toDouble();
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

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
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
                      const SizedBox(height: 40),
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
                                    _sliderValue = index.toDouble();
                                  });
                                  widget.onUpdate(_selectedLevel);
                                },
                                child: Text(
                                  _levelNames[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.14),
                          inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.12),
                          trackHeight: 6,
                          thumbColor: Colors.white,
                          overlayColor: AppColors.primaryBlue.withValues(alpha: 0.16),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          min: 0,
                          max: 2,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            setState(() {
                              _sliderValue = value;
                              final newLevel = value.clamp(0, 2).round();
                              if (newLevel != _selectedLevel) {
                                _selectedLevel = newLevel;
                                widget.onUpdate(_selectedLevel);
                              }
                            });
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
                      const SizedBox(height: 160), // Room for bottom nav bar
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: OnboardingNavBar(
            onNext: widget.onNext,
            onBack: widget.onBack,
          ),
        ),
      ],
    );
  }
}


