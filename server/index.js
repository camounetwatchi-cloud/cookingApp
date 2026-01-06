require('dotenv').config();
const express = require('express');
const multer = require('multer');
const fetch = require('node-fetch');

const cors = require('cors');
const upload = multer({ storage: multer.memoryStorage() });
const app = express();

// CORS: allow all origins in development
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const PORT = process.env.PORT || 8080;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const DEV_MOCK = process.env.DEV_MOCK === 'true';

// ============================================================================
// VALIDATION & FILTERING SYSTEM FOR FOOD DETECTION
// ============================================================================

// Blacklist: words that are definitely NOT food items
const BLACKLIST = new Set([
  // Technical terms / artifacts
  'json', 'data', 'file', 'image', 'photo', 'jpg', 'jpeg', 'png', 'gif', 'webp',
  'http', 'https', 'www', 'com', 'fr', 'org', 'net', 'html', 'css', 'js',
  'null', 'undefined', 'true', 'false', 'error', 'ok', 'success',
  // Incomplete words / gibberish patterns
  'ch', 'tr', 'br', 'cr', 'dr', 'fr', 'gr', 'pr', 'vr', 'bl', 'cl', 'fl', 'gl', 'pl',
  'poivr', 'tomat', 'carro', 'oigno', 'pomm', 'beurr', 'fromagr', 'legu', 'frui',
  // Non-food words
  'chose', 'truc', 'machin', 'bidule', 'objet', 'item', 'element', 'produit',
  'autre', 'divers', 'etc', 'inconnu', 'non', 'oui', 'peut', 'etre',
  // Container words (not food themselves)  
  'boite', 'bocal', 'bouteille', 'sachet', 'paquet', 'emballage', 'contenant',
  'barquette', 'pot', 'tube', 'brique', 'carton', 'plastique', 'verre',
]);

// Useless adjectives to remove for cleaner output
const USELESS_ADJECTIVES = [
  'rond', 'ronde', 'ronds', 'rondes',
  'carré', 'carrée', 'carrés', 'carrées',
  'rectangulaire', 'rectangulaires',
  'long', 'longue', 'longs', 'longues',
  'petit', 'petite', 'petits', 'petites',
  'grand', 'grande', 'grands', 'grandes',
  'gros', 'grosse',
  'normal', 'normale', 'normaux', 'normales',
  'standard', 'classique', 'classiques',
  'simple', 'simples',
  'entier', 'entière', 'entiers', 'entières',
  'frais', 'fraîche', 'fraîches',
  'cru', 'crue', 'crus', 'crues',
];

// Valid French food categories for semantic validation
const FOOD_CATEGORIES = [
  // Légumes
  'tomate', 'carotte', 'oignon', 'ail', 'poivron', 'courgette', 'aubergine',
  'concombre', 'salade', 'laitue', 'épinard', 'chou', 'brocoli', 'chou-fleur',
  'haricot', 'petit pois', 'maïs', 'pomme de terre', 'patate', 'champignon',
  'poireau', 'céleri', 'fenouil', 'artichaut', 'asperge', 'betterave', 'navet',
  'radis', 'endive', 'cresson', 'mâche', 'roquette', 'avocat', 'courge',
  'potiron', 'butternut', 'citrouille', 'panais', 'topinambour', 'rutabaga',
  // Fruits
  'pomme', 'poire', 'banane', 'orange', 'citron', 'mandarine', 'clémentine',
  'pamplemousse', 'raisin', 'fraise', 'framboise', 'myrtille', 'mûre', 'cerise',
  'abricot', 'pêche', 'nectarine', 'prune', 'kiwi', 'mangue', 'ananas', 'melon',
  'pastèque', 'figue', 'grenade', 'litchi', 'fruit de la passion', 'papaye',
  // Produits laitiers
  'lait', 'fromage', 'beurre', 'crème', 'yaourt', 'yogourt', 'fromage blanc',
  'mascarpone', 'ricotta', 'mozzarella', 'parmesan', 'gruyère', 'comté',
  'camembert', 'brie', 'roquefort', 'chèvre', 'feta', 'emmental', 'cheddar',
  'crème fraîche', 'crème liquide', 'lait fermenté', 'kéfir', 'skyr',
  // Viandes
  'poulet', 'bœuf', 'porc', 'veau', 'agneau', 'dinde', 'canard', 'lapin',
  'jambon', 'bacon', 'lardons', 'saucisse', 'saucisson', 'chorizo', 'merguez',
  'steak', 'escalope', 'côtelette', 'rôti', 'filet', 'cuisse', 'aile',
  'viande hachée', 'boulette', 'pâté', 'terrine', 'foie gras',
  // Poissons et fruits de mer
  'saumon', 'thon', 'cabillaud', 'colin', 'bar', 'dorade', 'sole', 'truite',
  'sardine', 'maquereau', 'hareng', 'anchois', 'crevette', 'gambas', 'crabe',
  'homard', 'langouste', 'moule', 'huître', 'coquille saint-jacques', 'poulpe',
  'calamar', 'seiche', 'surimi',
  // Œufs
  'œuf', 'oeuf', 'œufs', 'oeufs',
  // Céréales et féculents
  'pain', 'baguette', 'riz', 'pâtes', 'spaghetti', 'tagliatelle', 'penne',
  'quinoa', 'boulgour', 'semoule', 'couscous', 'polenta', 'farine', 'maïzena',
  'flocons d\'avoine', 'céréales', 'muesli', 'granola', 'brioche', 'croissant',
  // Condiments et épices
  'sel', 'poivre', 'huile', 'vinaigre', 'moutarde', 'mayonnaise', 'ketchup',
  'sauce soja', 'sauce tomate', 'pesto', 'harissa', 'curry', 'cumin', 'paprika',
  'thym', 'romarin', 'basilic', 'persil', 'coriandre', 'menthe', 'ciboulette',
  'origan', 'laurier', 'cannelle', 'muscade', 'gingembre', 'curcuma', 'safran',
  // Sucré
  'sucre', 'miel', 'confiture', 'chocolat', 'nutella', 'cacao', 'vanille',
  'sirop', 'caramel', 'pâte à tartiner',
  // Boissons
  'eau', 'jus', 'lait', 'café', 'thé', 'soda', 'coca', 'limonade', 'bière',
  'vin', 'cidre', 'jus d\'orange', 'jus de pomme',
  // Autres
  'tofu', 'tempeh', 'seitan', 'lait de soja', 'lait d\'amande', 'lait de coco',
  'crème de coco', 'olive', 'cornichon', 'câpre',
];

/**
 * Check if a string looks like gibberish (random characters, not a real word)
 */
function isGibberish(str) {
  const s = str.toLowerCase().trim();

  // Too short to be meaningful
  if (s.length < 3) return true;

  // Only consonants (no vowels) - likely incomplete
  const vowels = /[aeiouyàâäéèêëïîôùûüœæ]/i;
  if (!vowels.test(s)) return true;

  // Too many consonants in a row (more than 4)
  if (/[bcdfghjklmnpqrstvwxz]{5,}/i.test(s)) return true;

  // Contains special characters that shouldn't be in food names
  if (/[{}[\]<>@#$%^&*()+=|\\~`]/.test(s)) return true;

  // Contains numbers (food names don't have numbers)
  if (/\d/.test(s)) return true;

  return false;
}

/**
 * Normalize a food item name: remove useless adjectives, fix formatting
 */
function normalizeFood(item) {
  let s = item.toLowerCase().trim();

  // Remove useless adjectives
  for (const adj of USELESS_ADJECTIVES) {
    // Match adjective as a separate word
    const regex = new RegExp(`\\b${adj}\\b\\s*`, 'gi');
    s = s.replace(regex, '');
  }

  // Clean up extra spaces
  s = s.replace(/\s+/g, ' ').trim();

  // Capitalize first letter
  if (s.length > 0) {
    s = s.charAt(0).toUpperCase() + s.slice(1);
  }

  return s;
}

/**
 * Check if an item is semantically valid as a food item
 */
function isFoodLike(item) {
  const s = item.toLowerCase().trim();

  // Check against known food categories
  for (const food of FOOD_CATEGORIES) {
    if (s.includes(food) || food.includes(s)) {
      return true;
    }
  }

  // If not in our list, apply heuristics:
  // - Must have at least 3 characters
  // - Must not be too long (likely a sentence, not a food name)
  // - Must have vowels (real French word)
  if (s.length >= 3 && s.length <= 35) {
    const vowels = /[aeiouyàâäéèêëïîôùûüœæ]/i;
    if (vowels.test(s)) {
      return true;
    }
  }

  return false;
}

/**
 * Validate and filter food items from AI response
 */
function validateFoodItems(items) {
  console.log('Validating', items.length, 'items from Gemini');

  const validated = items
    // Basic string cleanup
    .map(item => typeof item === 'string' ? item.trim() : '')
    .filter(item => item.length > 0)

    // Remove blacklisted terms
    .filter(item => {
      const lower = item.toLowerCase();
      if (BLACKLIST.has(lower)) {
        console.log(`Filtered (blacklist): "${item}"`);
        return false;
      }
      return true;
    })

    // Remove gibberish
    .filter(item => {
      if (isGibberish(item)) {
        console.log(`Filtered (gibberish): "${item}"`);
        return false;
      }
      return true;
    })


    // Normalize names
    .map(item => normalizeFood(item))

    // Remove duplicates (case insensitive)
    .filter((item, index, arr) => {
      const lower = item.toLowerCase();
      return arr.findIndex(x => x.toLowerCase() === lower) === index;
    })

    // Final length filter
    .filter(item => item.length >= 3 && item.length <= 50);

  console.log('Validated items:', validated);
  return validated;
}

// ============================================================================
// API ENDPOINT
// ============================================================================

app.post('/api/fridge', upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Missing file' });

    const imageBase64 = req.file.buffer.toString('base64');
    // Fix MIME type - Gemini only accepts specific image types
    let mimeType = req.file.mimetype || 'image/jpeg';
    const validMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!validMimeTypes.includes(mimeType)) {
      console.log(`Invalid mime type: ${mimeType}, defaulting to image/jpeg`);
      mimeType = 'image/jpeg';
    }
    console.log(`Processing image with mime type: ${mimeType}`);

    // Development mock
    if (DEV_MOCK) {
      return res.json({ items: ['Tomate', 'Fromage', 'Lait', 'Œufs'] });
    }

    if (!GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Server not configured: missing GEMINI_API_KEY' });
    }

    // Optimized prompt for PRECISION over quantity
    const optimizedPrompt = `Tu es un expert en reconnaissance d'aliments. Analyse cette image avec PRÉCISION et FIABILITÉ.

RÈGLES CRITIQUES:
1. NE LISTE QUE les aliments que tu identifies avec CERTITUDE (90%+ confiance)
2. Si tu n'es pas sûr, NE L'INCLUS PAS - mieux vaut omettre que halluciner
3. Utilise des noms d'aliments FRANÇAIS NATURELS et COMPLETS
4. PAS d'adjectifs inutiles (pas "tomate ronde", juste "tomate")
5. PAS de mots incomplets (pas "poivr", mais "poivre" ou "poivron")
6. PAS de termes techniques ou de format (pas "json", "data", etc.)

EXEMPLES DE BONS NOMS:
✅ "tomate", "lait", "œufs", "fromage", "beurre", "poulet", "carotte"
✅ "tomate cerise" (variété spécifique = OK)
✅ "crème fraîche", "sauce tomate", "huile d'olive"

EXEMPLES À ÉVITER:
❌ "tomate ronde" (redondant)
❌ "poivr" (incomplet)
❌ "ch" ou "json" (pas des aliments)
❌ "produit laitier non identifié" (trop vague)

FORMAT OBLIGATOIRE:
Retourne UNIQUEMENT un tableau JSON de strings en français.
Exemple: ["tomate", "lait", "œufs", "fromage"]

Si tu ne vois aucun aliment identifiable avec certitude, retourne: []

IMPORTANT: La qualité prime sur la quantité. Ne liste que ce que tu vois VRAIMENT.`;

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;

    const payload = {
      contents: [
        {
          parts: [
            { text: optimizedPrompt },
            {
              inline_data: {
                mime_type: mimeType,
                data: imageBase64
              }
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.1,  // Low temperature for consistency
        maxOutputTokens: 8192  // Increased to account for thinking tokens in Gemini 2.5 Flash
      }
    };

    console.log('Calling Gemini API with optimized prompt...');
    const apiRes = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!apiRes.ok) {
      const text = await apiRes.text();
      console.error('Gemini API error:', text);
      return res.status(502).json({ error: 'AI service error', details: text });
    }

    const aiJson = await apiRes.json();

    // Extract and validate response
    let items = [];
    try {
      const textResponse = aiJson.candidates?.[0]?.content?.parts?.[0]?.text || '';
      console.log('Gemini response length:', textResponse.length, 'chars');

      // Parse JSON array - cleanup markdown and extract
      // Remove markdown code blocks if present
      let cleanText = textResponse.replace(/```json\s*/gi, '').replace(/```\s*/gi, '');

      const jsonMatch = cleanText.match(/\[[\s\S]*\]/);
      console.log('JSON match found:', !!jsonMatch);
      if (jsonMatch) {
        try {
          const parsedItems = JSON.parse(jsonMatch[0]);
          if (Array.isArray(parsedItems)) {
            // Apply our validation pipeline
            items = validateFoodItems(parsedItems);
          }
        } catch (jsonErr) {
          console.log('JSON parse error, response may be truncated');
        }
      } else {
        console.log('No JSON array found in response');
      }

      if (items.length === 0) {
        console.log('No valid items after filtering');
        // Return empty array instead of placeholder text
        items = [];
      }

      console.log(`Final result: ${items.length} valid food items:`, items);
    } catch (parseErr) {
      console.error('Parse error:', parseErr);
      items = [];
    }

    return res.json({ items });
  } catch (err) {
    console.error('Server error:', err);
    return res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

app.get('/', (req, res) => res.send('CookingApp server running'));

app.listen(PORT, '0.0.0.0', () => console.log(`Server listening on ${PORT} (0.0.0.0)`));
