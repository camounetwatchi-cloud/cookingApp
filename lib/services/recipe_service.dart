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
  static Future<List<Map<String, dynamic>>?> generateRecipes({
    required List<String> ingredients,
    FoodPreferences? preferences,
    int maxRecipes = 6,
  }) async {
    try {
      final prompt = _buildPrompt(ingredients, preferences, maxRecipes);
      
      final response = await http.post(
        Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openRouterApiKey}',
          'HTTP-Referer': ApiConfig.appUrl,
          'X-Title': ApiConfig.appName,
        },
        body: jsonEncode({
          'model': ApiConfig.modelName,
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
9. IMAGES : Pour chaque recette, fournis TOUJOURS une URL d'image Unsplash pertinente pour illustrer le plat.

Si les ingrédients fournis ne permettent pas de faire une recette mangeable, réponds : {"erreur": "Combinaison impossible"}.
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
        return recipes;
      } else {
        print('OpenRouter API error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error generating recipes: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
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
      "image": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
      "ingredients": [
        {"name": "Tomates", "quantity": "200 g"},
        {"name": "Pâtes", "quantity": "150 g"}
      ],
      "equipment": ["Plaques de cuisson", "Poêle"],
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
        
        // Robust image fallback
        String imageUrl = recipeMap['image'] ?? '';
        if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
          imageUrl = _getPlaceholderImage(title);
        }
        
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

  /// Get a relevant placeholder image based on the recipe title
  static String _getPlaceholderImage(String title) {
    final t = title.toLowerCase();
    
    if (t.contains('pasta') || t.contains('pâte') || t.contains('spaghetti')) {
      return 'https://images.unsplash.com/photo-1473093226795-af9932fe5856';
    }
    if (t.contains('salade') || t.contains('salad') || t.contains('légume')) {
      return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd';
    }
    if (t.contains('soupe') || t.contains('soup') || t.contains('potage')) {
      return 'https://images.unsplash.com/photo-1547592166-23ac45744acd';
    }
    if (t.contains('dessert') || t.contains('gâteau') || t.contains('chocolat') || t.contains('sucré')) {
      return 'https://images.unsplash.com/photo-1488477181946-6428a0291777';
    }
    if (t.contains('poulet') || t.contains('chicken') || t.contains('viande') || t.contains('beef') || t.contains('bœuf')) {
      return 'https://images.unsplash.com/photo-1432139555190-58524dae6a55';
    }
    if (t.contains('poisson') || t.contains('fish') || t.contains('saumon')) {
      return 'https://images.unsplash.com/photo-1467003909585-2f8a72700288';
    }
    
    // Default high-quality food image
    return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836';
  }
}
