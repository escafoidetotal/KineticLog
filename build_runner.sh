#!/bin/bash
# Script de configuración inicial de KineticLog
# Ejecuta ESTE SCRIPT antes de la primera compilación

echo "========================================"
echo "  KineticLog — Setup inicial"
echo "========================================"

echo ""
echo "1. Instalando dependencias..."
flutter pub get

echo ""
echo "2. Generando código de Isar (modelos de BD)..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "3. Listo! Ahora puedes compilar:"
echo "   flutter run"
echo ""
echo "IMPORTANTE antes de publicar en Google Play:"
echo "  - Reemplaza los IDs de AdMob en lib/core/constants/ad_constants.dart"
echo "  - Actualiza APP_ID en AndroidManifest.xml"
echo "  - Firma la app con tu keystore de produccion"
echo "========================================"
