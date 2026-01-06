@echo off
title Lancer CookingApp - Backend + Frontend
SETLOCAL ENABLEEXTENSIONS

:: Couleurs pour le terminal
:: 0 = Noir, 7 = Blanc, 2 = Vert, 6 = Jaune, 3 = Cyan
color 0B

echo ================================================================
echo           LANCEMENT COMPLET DE COOKING APP
echo ================================================================
echo.

:: Detection du repertoire courant
cd /d "%~dp0"

:: 1. Verification et lancement du serveur Node.js (Backend)
echo [1/2] Preparation du backend...
if exist "server\package.json" (
    cd server
    if not exist node_modules (
        echo [INFO] Installation des dependances du serveur...
        echo        Cela peut prendre un moment.
        call npm install
    )
    echo [OK] Backend pret.
    echo [INFO] Demarrage du serveur dans une nouvelle fenetre...
    :: On lance le serveur via cmd /k pour que la fenetre reste ouverte en cas d'erreur
    start "CookingApp Server (Port 8080)" cmd /k "npm start"
    cd ..
) else (
    echo [ATTENTION] Dossier 'server' ou 'package.json' introuvable.
    echo Le backend ne pourra pas etre lance automatiquement.
)

:: Petite pause pour laisser le serveur s'initialiser
timeout /t 3 /nobreak > nul

echo.

:: 2. Verification et lancement de l'application Flutter (Frontend)
echo [2/2] Preparation du frontend Flutter...
if exist "pubspec.yaml" (
    echo [INFO] Verification des packages Flutter...
    call flutter pub get
    echo [OK] Frontend pret.
    echo.
    echo ================================================================
    echo   L'APPLICATION VA MAINTENANT DEMARRER.
    echo   Cible par defaut : Windows ^(Desktop^)
    echo   Veuillez patienter pendant la compilation...
    echo ================================================================
    echo.
    :: Lancement de l'application sur Windows (Desktop)
    :: Si vous voulez lancer sur un portable, branchez-le et remplacez '-d windows' par '-d android' ou retirez-le.
    call flutter run -d windows
) else (
    echo [ERREUR] Fichier 'pubspec.yaml' introuvable ! 
    echo Assurez-vous d'etre dans le bon dossier.
    pause
)

echo.
echo ================================================================
echo   Fin du script.
echo ================================================================
pause
