import 'package:flutter/material.dart';
import 'allergies_page.dart';
import 'skill_level_page.dart';
import 'pantry_basics_page.dart';
import 'cuisine_preferences_page.dart';
import 'kitchen_equipment_page.dart';
import 'dislikes_page.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingFlow({super.key, required this.onComplete});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 6;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - complete onboarding
      widget.onComplete();
    }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots - aligned left, black/grey style
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_totalPages, (index) {
                  final isCompleted = index <= _currentPage;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.black87
                          : Colors.grey[300],
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
                  AllergiesPage(onNext: _nextPage),
                  SkillLevelPage(onNext: _nextPage, onBack: _previousPage),
                  PantryBasicsPage(onNext: _nextPage, onBack: _previousPage),
                  CuisinePreferencesPage(onNext: _nextPage, onBack: _previousPage),
                  KitchenEquipmentPage(onNext: _nextPage, onBack: _previousPage),
                  DislikesPage(onNext: _nextPage, onBack: _previousPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
