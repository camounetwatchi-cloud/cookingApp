require('dotenv').config();
const express = require('express');
const multer = require('multer');
const fetch = require('node-fetch');
const {GoogleAuth} = require('google-auth-library');

const upload = multer({ storage: multer.memoryStorage() });
const app = express();
app.use(express.json({ limit: '10mb' }));

const PORT = process.env.PORT || 8080;

// Configuration via env
// AI Studio endpoint: if not set, code will try to build a Vertex AI predict URL
const PROJECT_ID = process.env.GCP_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT || '';
const LOCATION = process.env.AI_LOCATION || 'us-central1';
const MODEL = process.env.AI_MODEL || '';
const AI_STUDIO_ENDPOINT = process.env.AI_STUDIO_ENDPOINT || '';

async function getAccessToken() {
  const auth = new GoogleAuth({ scopes: ['https://www.googleapis.com/auth/cloud-platform'] });
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  return token.token;
}

app.post('/api/fridge', upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Missing file' });

    const imageBase64 = req.file.buffer.toString('base64');

    // Determine endpoint
    let endpoint = AI_STUDIO_ENDPOINT;
    if (!endpoint) {
      if (!PROJECT_ID || !MODEL) {
        return res.status(500).json({ error: 'Server not configured with AI_STUDIO_ENDPOINT or PROJECT_ID+MODEL' });
      }
      endpoint = `https://${LOCATION}-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/${LOCATION}/models/${MODEL}:predict`;
    }

    // Obtain access token from service account (works on Cloud Run with proper identity)
    const token = await getAccessToken();

    // Build request payload - adapt to your AI Studio model's expected format.
    const payload = {
      instances: [
        {
          // Many Vision/Vertex models expect bytes in content or a uri field
          content: imageBase64,
        },
      ],
    };

    const apiRes = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload),
    });

    if (!apiRes.ok) {
      const text = await apiRes.text();
      console.error('AI Studio error:', text);
      return res.status(502).json({ error: 'AI service error' });
    }

    const aiJson = await apiRes.json();

    // Map the AI response to a minimal items array. Adjust based on actual response schema.
    const items = [];
    if (aiJson.predictions && Array.isArray(aiJson.predictions)) {
      for (const p of aiJson.predictions) {
        if (typeof p === 'string') items.push(p);
        else if (p.displayName) items.push(p.displayName);
        else if (p.name) items.push(p.name);
      }
    }

    // If no items detected, try to fall back to examining payload or content
    if (items.length === 0 && aiJson && aiJson[0]) {
      // naive search for strings
      const dump = JSON.stringify(aiJson);
      // simple regex to extract words (this is a fallback only)
      const matches = dump.match(/\b[a-zA-Z]{3,20}\b/g);
      if (matches) {
        // return unique first N
        const uniq = Array.from(new Set(matches)).slice(0, 20);
        return res.json({ items: uniq });
      }
    }

    return res.json({ items });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/', (req, res) => res.send('CookingApp server running'));

app.listen(PORT, () => console.log(`Server listening on ${PORT}`));
