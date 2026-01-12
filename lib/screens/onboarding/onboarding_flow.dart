import 'package:flutter/material.dart';
import '../../models/food_preferences.dart';
import 'allergies_page.dart';
import 'pantry_basics_page.dart';
import 'kitchen_equipment_page.dart';
import '../../ui/design_system.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;
  final String userId;
  final FoodPreferences? existingPreferences;
  
  const OnboardingFlow({
    super.key,
    required this.onComplete,
    required this.userId,
    this.existingPreferences,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  // Preferences data
  late Set<String> _allergies;
  late Set<String> _pantryBasics;
  late Set<String> _kitchenEquipment;

  @override
  void initState() {
    super.initState();
    // Initialize with existing preferences or empty
    if (widget.existingPreferences != null) {
      _allergies = Set.from(widget.existingPreferences!.allergies);
      _pantryBasics = Set.from(widget.existingPreferences!.pantryBasics);
      _kitchenEquipment = Set.from(widget.existingPreferences!.kitchenEquipment);
    } else {
      _allergies = {};
      _pantryBasics = {};
      _kitchenEquipment = {};
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - save preferences and complete onboarding
      _savePreferences();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = FoodPreferences(
      allergies: _allergies,
      pantryBasics: _pantryBasics,
      kitchenEquipment: _kitchenEquipment,
      // Keep defaults for removed fields
      skillLevel: 0,
      cuisinePreferences: const {},
      spiceLevel: 0,
      dislikedItems: const {},
    );
    
    await FoodPreferences.saveForUser(widget.userId, prefs);
    widget.onComplete();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots - aligned left, Apple-like subtle dots
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 20.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_totalPages, (index) {
                  final isCompleted = index <= _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppColors.primaryBlue
                          : AppColors.textMuted.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  AllergiesPage(
                    onNext: _nextPage,
                    onUpdate: (allergies) => _allergies = allergies,
                    initialValue: _allergies,
                  ),
                  PantryBasicsPage(
                    onNext: _nextPage,
                    onBack: _previousPage,
                    onUpdate: (items) => _pantryBasics = items,
                    initialValue: _pantryBasics,
                  ),
                  KitchenEquipmentPage(
                    onNext: _nextPage,
                    onBack: _previousPage,
                    onUpdate: (equipment) => _kitchenEquipment = equipment,
                    initialValue: _kitchenEquipment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
