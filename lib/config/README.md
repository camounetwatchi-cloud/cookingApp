# Configuration de l'API OpenRouter

Ce fichier contient les informations nécessaires pour configurer l'API OpenRouter utilisée pour la génération de recettes par IA.

## Prérequis

1. Créer un compte sur [OpenRouter](https://openrouter.ai/)
2. Obtenir une clé API depuis votre compte

## Configuration

1. Copiez le fichier `api_config.example.dart` en `api_config.dart`
2. Remplacez `YOUR_OPENROUTER_API_KEY_HERE` par votre clé API réelle
3. Le fichier `api_config.dart` est dans `.gitignore` et ne sera pas commité

## Sécurité

⚠️ **IMPORTANT**: Ne jamais commiter le fichier `api_config.dart` contenant votre vraie clé API.

Le fichier est automatiquement ignoré par git grâce à l'entrée dans `.gitignore`.

## Modèle Utilisé

- **Modèle**: Mistral Small 3.1 24B (free tier)
- **Endpoint**: https://openrouter.ai/api/v1
- **Limite**: Gratuit, mais peut avoir des limites de taux

## Génération de Recettes

Le service génère jusqu'à 6 recettes authentiques basées sur :
- Les ingrédients disponibles dans le frigo
- Les allergies de l'utilisateur
- Les préférences culinaires
- L'équipement de cuisine disponible
- Les ingrédients non appréciés

## Dépannage

Si les recettes ne se génèrent pas :
1. Vérifiez que votre clé API est valide
2. Vérifiez votre connexion internet
3. Consultez la console pour les erreurs
4. L'app utilisera les recettes statiques en fallback
