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
const DEV_MOCK = process.env.DEV_MOCK === 'true' || true; // Enable dev mock by default

app.post('/api/fridge', upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Missing file' });

    const imageBase64 = req.file.buffer.toString('base64');
    // Fix MIME type - Gemini only accepts specific image types
    let mimeType = req.file.mimetype || 'image/jpeg';
    // If mime type is not a valid image type, default to jpeg
    const validMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!validMimeTypes.includes(mimeType)) {
      console.log(`Invalid mime type: ${mimeType}, defaulting to image/jpeg`);
      mimeType = 'image/jpeg';
    }
    console.log(`Processing image with mime type: ${mimeType}`);

    // Development mock: return sample items without calling AI Studio
    if (DEV_MOCK) {
      return res.json({ items: ['tomato', 'cheese', 'milk', 'eggs'] });
    }

    if (!GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Server not configured: missing GEMINI_API_KEY' });
    }

    // Call Gemini API (Google AI Studio) with vision capability
    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`;

    const payload = {
      contents: [
        {
          parts: [
            {
              text: "Analyze this image of a fridge or food items. List all the food items and ingredients you can see. Return ONLY a JSON array of strings with the item names in French (e.g., [\"tomate\", \"fromage\", \"lait\"]). Do not include any other text, just the JSON array."
            },
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
        temperature: 0.2,
        maxOutputTokens: 1024
      }
    };

    console.log('Calling Gemini API...');
    const apiRes = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload),
    });

    if (!apiRes.ok) {
      const text = await apiRes.text();
      console.error('Gemini API error:', text);
      return res.status(502).json({ error: 'AI service error', details: text });
    }

    const aiJson = await apiRes.json();
    console.log('Gemini response:', JSON.stringify(aiJson, null, 2));

    // Extract the text response from Gemini
    let items = [];
    try {
      const textResponse = aiJson.candidates?.[0]?.content?.parts?.[0]?.text || '';
      console.log('Text response:', textResponse);
      
      // Try to parse the JSON array from the response
      const jsonMatch = textResponse.match(/\[[\s\S]*\]/);
      if (jsonMatch) {
        items = JSON.parse(jsonMatch[0]);
      } else {
        // Fallback: split by newlines or commas if not valid JSON
        items = textResponse.split(/[,\n]/).map(s => s.trim()).filter(s => s.length > 0 && s.length < 50);
      }
    } catch (parseErr) {
      console.error('Parse error:', parseErr);
      // Return raw text as single item if parsing fails
      const rawText = aiJson.candidates?.[0]?.content?.parts?.[0]?.text || 'No items detected';
      items = [rawText];
    }

    return res.json({ items });
  } catch (err) {
    console.error('Server error:', err);
    return res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

app.get('/', (req, res) => res.send('CookingApp server running'));

app.listen(PORT, '0.0.0.0', () => console.log(`Server listening on ${PORT} (0.0.0.0)`));
