@echo off
echo ========================================
echo Limpiando proyecto Flutter...
echo ========================================
flutter clean

echo.
echo ========================================
echo Obteniendo dependencias...
echo ========================================
flutter pub get

echo.
echo ========================================
echo Construyendo APK de release...
echo ========================================
flutter build apk --release

echo.
echo ========================================
echo APK construido exitosamente!
echo ========================================
echo El APK se encuentra en: build\app\outputs\flutter-apk\app-release.apk
pause




