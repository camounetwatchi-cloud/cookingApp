cookingApp

Initialisation et synchronisation Git - instructions concises:

# Initialiser un dépôt local (si pas cloné):
git init
git add .
git commit -m "Init local"
git branch -M main
git remote add origin https://github.com/camounetwatchi-cloud/cookingApp.git
git push -u origin main

# Cloner (depuis une autre machine):
git clone https://github.com/camounetwatchi-cloud/cookingApp.git

# Mettre à jour local (pull):
git pull origin main

# Envoyer des changements (push):
git add <fichiers>
git commit -m "message bref"
git push origin main
