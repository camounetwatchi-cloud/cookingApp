import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/food_preferences.dart';

/// Service for generating recipes using OpenRouter AI
class RecipeService {
  /// Generate recipes based on available ingredients and user preferences
  /// 
  /// Returns a list of recipe maps containing title, ingredients, steps, etc.
  /// Returns null if the API call fails.
  // List of fallback models to ensure high availability
  static const List<String> _fallbackModels = [
    'google/gemini-2.0-flash-exp:free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'mistralai/mistral-7b-instruct:free',
  ];

  /// Generate recipes based on available ingredients and user preferences
  /// 
  /// Returns a list of recipe maps containing title, ingredients, steps, etc.
  /// Returns null if the API call fails.
  static Future<List<Map<String, dynamic>>?> generateRecipes({
    required List<String> ingredients,
    FoodPreferences? preferences,
    int maxRecipes = 6,
  }) async {
    final prompt = _buildPrompt(ingredients, preferences, maxRecipes);
    
    // Create prioritized list of models to try
    // 1. Primary config model
    // 2. Secondary config model (if different)
    // 3. Hardcoded high-quality free fallbacks
    final modelsToTry = <String>{
      ApiConfig.modelName,

      ..._fallbackModels,
    }.toList();

    for (final model in modelsToTry) {
      try {
        if (kDebugMode) {
          debugPrint('🚀 Generating recipes using model: $model');
        }
        
        final response = await http.post(
          Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConfig.openRouterApiKey}',
            'HTTP-Referer': ApiConfig.appUrl,
            'X-Title': ApiConfig.appName,
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {
                'role': 'system',
                'content': '''Tu es Chef Paul, un chef cuisinier triplement étoilé au Guide Michelin. 
Ta mission est de mentorat : tu guides l'utilisateur (ton apprenti) pour transformer ses simples ingrédients en créations gastronomiques.

TON DE VOIX :
- Professionnel, exigeant mais encourageant.
- Tu appelles l'utilisateur "Chef" ou "mon apprenti".
- Tu utilises un vocabulaire culinaire précis (ex: "Saisir", "Déglacer", "Réduction", "Dresser").
- Tes titres de recettes doivent être élégants et dignes d'une carte de grand restaurant.

RÈGLES D'OR DE PAUL :
1. N'utilise QUE les ingrédients listés + les basiques indispensables (sel, poivre, huile d'olive, beurre, farine, ail/échalote si dispo).
2. GASTRONOMIE RÉELLE : Propose des recettes qui existent ou qui sont des classiques revisités avec brio. PAS de noms fantaisistes.
3. ÉLÉGANCE : Même une omelette devient "L'Omelette Signature aux fines herbes".
4. PRÉCISION : Les étapes doivent être claires, directes, sans fioritures.
5. FORMAT : Réponds toujours sous forme de JSON structuré.
6. Si les ingrédients sont insuffisants pour une assiette digne de ce nom, réponds : {"erreur": "Ingrédients insuffisants pour une création de Chef"}.

Tu réponds toujours en JSON valide uniquement, sans texte avant ou après.'''
              },
              {
                'role': 'user',
                'content': prompt,
              }
            ],
            'temperature': 0.7,
            'max_tokens': 4000,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'] as String;
          
          // Parse the JSON response
          final recipes = _parseRecipesFromResponse(content);
          if (recipes.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('✅ Success with model: $model');
            }
            return recipes;
          } else {
             if (kDebugMode) {
               debugPrint('⚠️ Model $model returned empty or invalid recipes. Trying next...');
             }
          }
        } else {
          if (kDebugMode) {
            debugPrint('❌ Error with model $model: ${response.statusCode} - ${response.body}');
          }
          // Continue to next model loop
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Exception with model $model: $e');
        }
        // Continue to next model loop
      }
    }

    if (kDebugMode) {
      debugPrint('❌ All models failed to generate recipes.');
    }
    return null;
  }

  /// Build the prompt for the AI based on ingredients and preferences
  static String _buildPrompt(
    List<String> ingredients,
    FoodPreferences? preferences,
    int maxRecipes,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Crée exactement $maxRecipes recettes RÉELLES et AUTHENTIQUES basées sur les ingrédients suivants :');
    buffer.writeln();
    buffer.writeln('Ingrédients disponibles : ${ingredients.join(", ")}');
    buffer.writeln();
    
    if (preferences != null) {
      if (preferences.allergies.isNotEmpty) {
        buffer.writeln('⚠️ ALLERGIES À ÉVITER ABSOLUMENT : ${preferences.allergies.join(", ")}');
      }
      if (preferences.dislikedItems.isNotEmpty) {
        buffer.writeln('❌ Ingrédients non appréciés : ${preferences.dislikedItems.join(", ")}');
      }
      if (preferences.cuisinePreferences.isNotEmpty) {
        buffer.writeln('🌍 Préférences de cuisine : ${preferences.cuisinePreferences.join(", ")}');
      }
      if (preferences.kitchenEquipment.isNotEmpty) {
        buffer.writeln('🍳 Équipement disponible : ${preferences.kitchenEquipment.join(", ")}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('INSTRUCTIONS POUR LES RECETTES :');
    buffer.writeln('1. Utilise au MAXIMUM les ingrédients disponibles (au moins 3 ingrédients PAR recette)');
    buffer.writeln('2. Les recettes doivent être dignes d\'une carte de restaurant étoilé, visuellement magnifiques dans la description');
    buffer.writeln('3. Les recettes doivent rester réalisables pour un apprenti en 15-30 minutes');
    buffer.writeln('4. Respecte scrupuleusement les allergies et restrictions');
    buffer.writeln('5. Les quantités doivent être gastronomiques et précises');
    buffer.writeln('6. Le vocabulaire doit être celui d\'un Chef (ex: "Réserver", "Infuser", "Napper")');
    buffer.writeln();
    buffer.writeln('Réponds UNIQUEMENT avec un JSON valide dans ce format exact (sans texte avant ou après) :');
    buffer.writeln('''
{
  "recipes": [
    {
      "title": "Nom exact de la recette réelle",
      "time": "15 min",
      "difficulty": "Facile",
      "servings": "2 personnes",
      "equipment": ["Plaques de cuisson", "Poêle"],
      "ingredients": [
        {"name": "Tomates", "quantity": "200 g"},
        {"name": "Pâtes", "quantity": "150 g"}
      ],
      "allergyTags": ["Gluten"],
      "steps": [
        "Faire bouillir l'eau salée et cuire les pâtes 10 min.",
        "Couper les tomates en dés et les faire revenir 5 min.",
        "Mélanger les pâtes avec les tomates.",
        "Servir chaud avec du basilic frais."
      ],
      "stepsDetailed": [
        {
          "title": "Les pâtes",
          "description": "Faire bouillir l'eau salée et cuire les pâtes 10 min.",
          "durationLabel": "10 min",
          "durationMinutes": 10
        },
        {
          "title": "Les tomates",
          "description": "Couper les tomates en dés et les faire revenir 5 min.",
          "durationLabel": "5 min",
          "durationMinutes": 5
        }
      ]
    }
  ]
}
''');
    
    return buffer.toString();
  }

  /// Parse the AI response into a list of recipe maps
  static List<Map<String, dynamic>> _parseRecipesFromResponse(String content) {
    try {
      // Clean the response - remove any markdown code blocks
      String cleanContent = content.trim();
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      }
      if (cleanContent.startsWith('```')) {
        cleanContent = cleanContent.substring(3);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();
      
      final jsonData = jsonDecode(cleanContent) as Map<String, dynamic>;
      final recipesList = jsonData['recipes'] as List<dynamic>;
      
      return recipesList.map((recipe) {
        final recipeMap = recipe as Map<String, dynamic>;
        final title = recipeMap['title'] ?? 'Recette sans nom';
        
        // Generate consistently styled image using Pollinations AI
        // 1. Sanitize title (remove accents/special chars) to avoid URL issues
        final cleanTitle = _removeDiacritics(title);
        final encodedTitle = Uri.encodeComponent(cleanTitle);
        
        // 2. Build Pollinations URL
        final pollinationsUrl = 'https://image.pollinations.ai/prompt/professional_food_photography_of_${encodedTitle}_flat_lay_top_view_centered_on_white_porcelain_plate_minimalist_clean_background_soft_studio_lighting_high_contrast_8k?nologo=true';
        
        // 3. Use wsrv.nl proxy to bypass 403/CORS issues and ensure delivery
        final imageUrl = 'https://wsrv.nl/?url=${Uri.encodeComponent(pollinationsUrl)}&output=webp';
        
        // Ensure all required fields exist with defaults
        return {
          'title': title,
          'time': recipeMap['time'] ?? '15 min',
          'difficulty': recipeMap['difficulty'] ?? 'Moyen',
          'servings': recipeMap['servings'] ?? '2 personnes',
          'image': imageUrl,
          'ingredients': recipeMap['ingredients'] ?? [],
          'equipment': recipeMap['equipment'] ?? ['Plaques de cuisson'],
          'allergyTags': recipeMap['allergyTags'] ?? [],
          'steps': recipeMap['steps'] ?? [],
          'stepsDetailed': recipeMap['stepsDetailed'] ?? [],
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing recipes from response: $e');
        debugPrint('Response content: $content');
      }
      return [];
    }
  }

  /// Remove accents and diacritics from string for safer URLs
  static String _removeDiacritics(String str) {
    var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeedCcDIIIIiiiiUUUUuuuuNnSsYyyZz'; // Corresponding ASCII chars

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }
}


