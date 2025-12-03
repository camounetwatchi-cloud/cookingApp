# CookingApp - Server

This small Express server receives a photo (`/api/fridge`) and forwards it to AI Studio (Vertex AI) using a service account. It returns a minimal JSON `{ items: [...] }` with detected ingredients.

Security notes:
- Do NOT commit your service account JSON to the repository.
- Use `GOOGLE_APPLICATION_CREDENTIALS` for local testing or run on Cloud Run with the service account attached.
- Use Secret Manager for any additional secrets.

Quick local run:

```powershell
cd server
npm install
# set GOOGLE_APPLICATION_CREDENTIALS to point to your local service account json (local only)
$env:GOOGLE_APPLICATION_CREDENTIALS='C:\path\to\service-account.json'
$env:GCP_PROJECT_ID='892487267688'
$env:AI_MODEL='YOUR_MODEL_NAME'
node index.js
```

Deployment (recommended): Cloud Run

1. Create a service account `cookapp-ai-sa` and grant it the minimal roles required for Vertex AI (e.g., `roles/aiplatform.user` or more restrictive as needed) and `roles/secretmanager.secretAccessor` if you use Secret Manager.
2. Build and push container to Artifact Registry or Container Registry.
3. Deploy to Cloud Run and set `GCP_PROJECT_ID`, `AI_MODEL`, and `AI_LOCATION` env vars on the service. Attach the service account to the Cloud Run service.

If your AI Studio integration requires a different endpoint or payload, set `AI_STUDIO_ENDPOINT` env var to the full URL.
