import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/food_preferences.dart';

/// Service for generating recipes using OpenRouter AI
class RecipeService {
  /// Generate recipes based on available ingredients and user preferences
  /// 
  /// Returns a list of recipe maps containing title, ingredients, steps, etc.
  /// Returns null if the API call fails.
  static bool _useSecondaryModel = false;

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
      if (ApiConfig.secondaryModelName != ApiConfig.modelName) ApiConfig.secondaryModelName,
      ..._fallbackModels,
    }.toList();

    for (final model in modelsToTry) {
      try {
        print('🚀 Generating recipes using model: $model');
        
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
                'content': '''Tu es un chef cuisinier expert spécialisé dans la cuisine "anti-gaspi". 
Ta mission est de proposer des recettes RÉALISTES à partir d'une liste d'ingrédients.

RÈGLES STRICTES :
1. N'utilise QUE les ingrédients listés + les basiques (sel, poivre, huile, farine, eau, sucre, ail/oignon si dispo).
2. COHÉRENCE : Ne mélange pas des ingrédients qui ne vont pas ensemble (ex: pas de bière dans une salade de fruits). 
3. INTERDIT ABSOLU : NE JAMAIS faire de sucré-salé. Les recettes doivent être SOIT salées SOIT sucrées, jamais les deux.
4. RECETTES RÉELLES : Utilise UNIQUEMENT des noms de recettes qui existent vraiment (ex: "Quiche Lorraine", "Tarte Tatin", "Bœuf Bourguignon"). PAS de noms inventés.
5. SIMPLICITÉ : Propose des étapes de cuisson logiques et précises.
6. PRIORITÉ : Si un ingrédient est complexe (ex: "quiche" sous-entend une pâte), utilise-le comme base.
7. FORMAT : Réponds toujours sous forme de JSON structuré.
8. STYLE : Enlève les adverbes inutiles des recettes, sois direct et précis.
9. IMAGES : Ne fournis PAS d'URL d'image, nous la générons nous-mêmes.
10. Si les ingrédients fournis ne permettent pas de faire une recette mangeable, réponds : {"erreur": "Combinaison impossible"}.
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
            print('✅ Success with model: $model');
            return recipes;
          } else {
             print('⚠️ Model $model returned empty or invalid recipes. Trying next...');
          }
        } else {
          print('❌ Error with model $model: ${response.statusCode} - ${response.body}');
          // Continue to next model loop
        }
      } catch (e) {
        print('❌ Exception with model $model: $e');
        // Continue to next model loop
      }
    }

    print('❌ All models failed to generate recipes.');
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
    buffer.writeln('1. Utilise au MAXIMUM les ingrédients disponibles listés ci-dessus (au moins 3 ingrédients PAR recette)');
    buffer.writeln('2. Les recettes doivent être de VRAIES BONNES recettes professionnelles, appétissantes et qui donnent envie');
    buffer.writeln('3. Les recettes doivent être réalisables en 10-25 minutes');
    buffer.writeln('4. Chaque recette doit être différente et originale');
    buffer.writeln('5. Respecte ABSOLUMENT les allergies et restrictions si mentionnées');
    buffer.writeln('6. Les quantités doivent être précises');
    buffer.writeln('7. Pas d\'adverbes inutiles dans les étapes, sois direct');
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
      print('Error parsing recipes from response: $e');
      print('Response content: $content');
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


