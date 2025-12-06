import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FoodPreferences {
  final Set<String> allergies;
  final int skillLevel; // 0 = Debutant, 1 = Intermediaire, 2 = Avance
  final Set<String> pantryBasics;
  final Set<String> cuisinePreferences;
  final Set<String> kitchenEquipment;
  final int spiceLevel; // 0 = Pas epice, 1 = Un peu epice, 2 = Tres epice
  final Set<String> dislikedItems;

  FoodPreferences({
    required this.allergies,
    required this.skillLevel,
    required this.pantryBasics,
    required this.cuisinePreferences,
    required this.kitchenEquipment,
    required this.spiceLevel,
    required this.dislikedItems,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies.toList(),
      'skillLevel': skillLevel,
      'pantryBasics': pantryBasics.toList(),
      'cuisinePreferences': cuisinePreferences.toList(),
      'kitchenEquipment': kitchenEquipment.toList(),
      'spiceLevel': spiceLevel,
      'dislikedItems': dislikedItems.toList(),
    };
  }

  // Create from JSON
  factory FoodPreferences.fromJson(Map<String, dynamic> json) {
    return FoodPreferences(
      allergies: Set<String>.from(json['allergies'] as List? ?? []),
      skillLevel: json['skillLevel'] as int? ?? 0,
      pantryBasics: Set<String>.from(json['pantryBasics'] as List? ?? []),
      cuisinePreferences: Set<String>.from(json['cuisinePreferences'] as List? ?? []),
      kitchenEquipment: Set<String>.from(json['kitchenEquipment'] as List? ?? []),
      spiceLevel: json['spiceLevel'] as int? ?? 0,
      dislikedItems: Set<String>.from(json['dislikedItems'] as List? ?? []),
    );
  }

  // Empty preferences
  factory FoodPreferences.empty() {
    return FoodPreferences(
      allergies: {},
      skillLevel: 0,
      pantryBasics: {},
      cuisinePreferences: {},
      kitchenEquipment: {},
      spiceLevel: 0,
      dislikedItems: {},
    );
  }

  // Save to SharedPreferences
  static Future<void> saveForUser(String userId, FoodPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'food_preferences_$userId';
    final json = jsonEncode(preferences.toJson());
    await prefs.setString(key, json);
  }

  // Load from SharedPreferences
  static Future<FoodPreferences?> loadForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'food_preferences_$userId';
    final json = prefs.getString(key);
    if (json == null) return null;
    try {
      return FoodPreferences.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      print('Error loading food preferences: $e');
      return null;
    }
  }

  // Delete from SharedPreferences
  static Future<void> deleteForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'food_preferences_$userId';
    await prefs.remove(key);
  }
}
