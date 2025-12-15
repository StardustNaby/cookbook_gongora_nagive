-- Migración para actualizar URLs de imágenes de Google Share a URLs directas
-- Ejecuta este script en Supabase SQL Editor si tienes recetas con URLs de Google Share

-- Actualizar URL de "Papas a la francesa" (o receta similar)
-- Reemplaza 'RECIPE_ID_1' con el ID real de tu receta de papas
UPDATE recipes 
SET image_url = 'https://www.johaprato.com/files/styles/flexslider_full/public/papas_fritas.jpg?itok=VaKy_ix9'
WHERE image_url LIKE '%share.google%' 
  AND (name ILIKE '%papa%' OR name ILIKE '%frita%' OR name ILIKE '%french%');

-- Actualizar URL de "Pastel de fresa" (o receta similar)
-- Reemplaza 'RECIPE_ID_2' con el ID real de tu receta de pastel
UPDATE recipes 
SET image_url = 'https://i.pinimg.com/736x/97/32/fb/9732fbf43434915aa777468897715690.jpg'
WHERE image_url LIKE '%share.google%' 
  AND (name ILIKE '%pastel%' OR name ILIKE '%fresa%' OR name ILIKE '%strawberry%');

-- Si quieres actualizar TODAS las URLs de Google Share a null (para que se muestre placeholder)
-- Descomenta la siguiente línea:
-- UPDATE recipes SET image_url = NULL WHERE image_url LIKE '%share.google%';




