# 🎀 CookBook Coquette - Mi Recetario Personal

Una aplicación móvil desarrollada en Flutter para gestionar, crear y organizar recetas de cocina personales. Este proyecto combina una arquitectura limpia y robusta con una estética "Coquette" única, ofreciendo una experiencia de usuario fluida y visualmente agradable.

**Desarrollado por:** [Tu Nombre Completo Aquí]

**Versión:** 1.0.0

---

## ✨ Características Principales

* **Autenticación Segura:** Login y Registro con correo electrónico (Supabase Auth).

* **Gestión de Recetas (CRUD):** Crear, Leer, Actualizar y Eliminar recetas.

* **Ingredientes y Pasos Dinámicos:** Agrega tantos ingredientes y pasos como necesites.

* **Reordenamiento:** Organiza los pasos de tu receta arrastrando y soltando (Drag & Drop).

* **Favoritos:** Guarda tus recetas preferidas para acceso rápido.

* **Búsqueda y Filtros:** Encuentra recetas por nombre o filtra por dificultad.

* **Ordenamiento:** Ordena recetas por fecha, alfabético o tiempo de preparación.

* **Pull-to-Refresh:** Arrastra hacia abajo para actualizar la lista de recetas.

* **Modo Oscuro 🌙:** Interfaz adaptable a temas claro y oscuro con toggle manual.

* **Perfil de Usuario:** Gestión de sesión y visualización de datos básicos.

* **Estética Coquette:** Diseño cuidado con bordes redondeados, paleta de colores pastel y tipografías elegantes.

---

## 📸 Capturas de Pantalla

| Inicio (Grid) | Detalle de Receta | Crear Receta |
|:---:|:---:|:---:|
| ![Home](docs/screenshots/home.png) | ![Detail](docs/screenshots/detail.png) | ![Create](docs/screenshots/create.png) |

| Modo Oscuro | Perfil | Favoritos |
|:---:|:---:|:---:|
| ![Dark Mode](docs/screenshots/dark_mode.png) | ![Profile](docs/screenshots/profile.png) | ![Favorites](docs/screenshots/favorites.png) |

---

## 🛠️ Tecnologías Utilizadas

* **Framework:** Flutter (Dart)

* **Gestor de Estado:** Riverpod (StateNotifier & Providers)

* **Navegación:** GoRouter (con ShellRoute para navegación anidada)

* **Backend & Base de Datos:** Supabase (PostgreSQL + Auth)

* **UI/UX:** Google Fonts, Lottie Animations, Cached Network Image.

---

## 🗄️ Estructura de Base de Datos

El proyecto utiliza **Supabase (PostgreSQL)**. Aquí tienes el diagrama relacional:

```
┌─────────────────┐
│  auth.users     │
│  (Supabase)     │
└────────┬────────┘
         │
         │ user_id (FK)
         │
┌────────▼────────┐
│    recipes      │
├─────────────────┤
│ id (PK, UUID)   │
│ user_id (FK)    │
│ name            │
│ description     │
│ prep_time_min   │
│ servings        │
│ difficulty      │
│ image_url       │
│ is_favorite     │
│ created_at      │
│ updated_at      │
└────┬───────┬────┘
     │       │
     │       │ recipe_id (FK, ON DELETE CASCADE)
     │       │
┌────▼───┐ ┌─▼──────────┐
│ingred. │ │   steps    │
├────────┤ ├───────────┤
│id (PK) │ │id (PK)    │
│recipe_ │ │recipe_id  │
│  id    │ │description │
│name    │ │step_number│
│quantity│ └───────────┘
│unit    │
│order_  │
│ index  │
└────────┘
```

### Tablas:

1. **users (auth.users):** Gestionado internamente por Supabase.

2. **recipes:**
   * `id` (UUID, PK)
   * `user_id` (FK -> auth.users)
   * `name`, `description`, `difficulty`, `prep_time_minutes`, `is_favorite`, `image_url`, `created_at`, `updated_at`.

3. **ingredients:**
   * `id` (UUID, PK)
   * `recipe_id` (FK -> recipes, ON DELETE CASCADE)
   * `name`, `quantity`, `unit`, `order_index`.

4. **steps:**
   * `id` (UUID, PK)
   * `recipe_id` (FK -> recipes, ON DELETE CASCADE)
   * `description`, `step_number`.

### Seguridad (RLS):
- Row Level Security (RLS) activado en todas las tablas
- Políticas configuradas para que usuarios solo vean/editen sus propias recetas
- Eliminación en cascada: al borrar una receta, se eliminan automáticamente sus ingredientes y pasos

Las migraciones SQL están disponibles en `supabase/migrations/001_initial_schema.sql`.

---

## 🚀 Instrucciones de Setup (Instalación)

1.  **Clonar el repositorio:**

    ```bash
    git clone https://github.com/tu-usuario/cookbook-app.git
    cd cookbook-app
    ```

2.  **Instalar dependencias:**

    ```bash
    flutter pub get
    ```

3.  **Configurar Variables de Entorno:**

    * Crea un archivo `.env` en la raíz del proyecto.
    * Copia el contenido de `.env.example` y rellena tus claves de Supabase:
      ```
      SUPABASE_URL=tu_url_de_supabase
      SUPABASE_ANON_KEY=tu_clave_anonima
      ```

4.  **Ejecutar la App:**

    ```bash
    flutter run
    ```

## 🔧 Troubleshooting Común

### Problema: "Error al conectar con Supabase"
**Solución:** Verifica que el archivo `.env` tenga las credenciales correctas y que el proyecto Supabase esté activo.

### Problema: "No se muestran las recetas"
**Solución:** 
1. Verifica que estés autenticado correctamente
2. Revisa que las políticas RLS estén configuradas en Supabase
3. Asegúrate de que hayas creado al menos una receta

### Problema: "Las imágenes no se cargan"
**Solución:**
1. Verifica que las URLs de imágenes sean válidas y accesibles
2. Algunas URLs de Google Images pueden requerir headers especiales (ya implementado)
3. Si usas Google Share links, estos no funcionan directamente - usa URLs directas de imágenes

### Problema: "Error al guardar receta"
**Solución:**
1. Verifica que todos los campos requeridos estén llenos
2. Asegúrate de tener al menos 1 ingrediente y 1 paso
3. El nombre debe tener mínimo 3 caracteres
4. El tiempo de preparación debe estar entre 1-999 minutos

### Problema: "APK no muestra los cambios"
**Solución:**
1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Reconstruye el APK: `flutter build apk --release`
4. Desinstala la versión anterior antes de instalar la nueva

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── config/          # Configuración de Supabase
│   ├── constants/       # Constantes de la app
│   ├── router/          # Configuración de GoRouter
│   └── theme/           # Tema Coquette (claro/oscuro)
├── data/
│   ├── models/          # Modelos de datos (RecipeModel, etc.)
│   └── repositories/    # Implementación de repositorios
├── domain/
│   ├── entities/        # Entidades de dominio
│   └── repositories/    # Interfaces de repositorios
└── presentation/
    ├── providers/       # Providers de Riverpod
    ├── screens/         # Pantallas de la app
    └── widgets/         # Widgets reutilizables
```

---

## 🎨 Paleta de Colores Coquette

* **Rosa Principal:** `#FFC1CC`
* **Rosa Pastel:** `#FFE4E9`
* **Rosa Fuerte:** `#FF69B4`
* **Crema Suave:** `#FFF8EE`
* **Marrón Texto:** `#5D4037`

---

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

---

## 👤 Autor

**Tu Nombre Completo Aquí**

* GitHub: [@tu-usuario](https://github.com/tu-usuario)
* Email: tu-email@ejemplo.com

---

## 🙏 Agradecimientos

* Flutter Team
* Supabase Team
* Comunidad de desarrolladores Flutter
