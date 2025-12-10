# 🔧 Cómo Reconstruir el APK Correctamente

## ⚠️ Problema
Si el APK no muestra los cambios más recientes, es porque está usando una versión antigua compilada.

## ✅ Solución: Build Limpio

### Paso 1: Limpiar el proyecto
```bash
flutter clean
```

### Paso 2: Obtener dependencias
```bash
flutter pub get
```

### Paso 3: Construir el APK de release
```bash
flutter build apk --release
```

### Paso 4: Instalar el nuevo APK
El APK se encontrará en:
```
build\app\outputs\flutter-apk\app-release.apk
```

## 🚀 Método Rápido (Script)
Ejecuta el archivo `build_clean_apk.bat` que está en la raíz del proyecto.

## 📱 Instalación en el Dispositivo

1. **Desinstala la versión anterior** de la app en tu celular
2. **Transfiere el nuevo APK** al celular
3. **Instala el nuevo APK** (puede requerir permitir "Instalar desde fuentes desconocidas")

## ⚡ Build Rápido para Pruebas (Debug)
Si solo quieres probar rápidamente:
```bash
flutter run --release
```

## 🔍 Verificar que los Cambios Están Aplicados

Después de reconstruir, deberías ver:
- ✅ AppBar con título dinámico ("Mis Recetas" o "Recetas Favoritas")
- ✅ Botones de tema (sol/luna) y perfil en el AppBar
- ✅ Sin overflow en las tarjetas de recetas
- ✅ Modo claro por defecto
- ✅ Barra de navegación inferior funcional

## 🐛 Si Aún No Funciona

1. **Verifica que el código esté actualizado:**
   ```bash
   git pull
   ```

2. **Limpia completamente:**
   ```bash
   flutter clean
   rm -rf build/
   flutter pub get
   ```

3. **Reconstruye:**
   ```bash
   flutter build apk --release
   ```

4. **Desinstala completamente la app anterior** antes de instalar la nueva

