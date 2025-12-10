-- 1. Tabla de Recetas

create table recipes (
  id UUID primary key default gen_random_uuid (),
  user_id UUID references auth.users not null,
  name TEXT not null,
  description TEXT,
  prep_time_minutes INTEGER,
  servings INTEGER,
  difficulty TEXT check (difficulty in ('easy', 'medium', 'hard')),
  image_url TEXT,
  is_favorite BOOLEAN default false,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- 2. Tabla de Ingredientes (Con borrado en cascada)

create table ingredients (
  id UUID primary key default gen_random_uuid (),
  recipe_id UUID references recipes (id) on delete CASCADE,
  name TEXT not null,
  quantity TEXT,
  unit TEXT,
  order_index INTEGER
);

-- 3. Tabla de Pasos (Con borrado en cascada)

create table steps (
  id UUID primary key default gen_random_uuid (),
  recipe_id UUID references recipes (id) on delete CASCADE,
  description TEXT not null,
  step_number INTEGER
);

-- 4. Activar Seguridad (RLS)

alter table recipes ENABLE row LEVEL SECURITY;

alter table ingredients ENABLE row LEVEL SECURITY;

alter table steps ENABLE row LEVEL SECURITY;

-- 5. Políticas: Los usuarios solo ven y editan sus propias recetas

create policy "Usuarios ven sus propias recetas" on recipes for
select
  to authenticated using (
    (
      select
        auth.uid ()
    ) = user_id
  );

create policy "Usuarios crean sus recetas" on recipes for INSERT to authenticated
with
  check (
    (
      select
        auth.uid ()
    ) = user_id
  );

create policy "Usuarios actualizan sus recetas" on recipes
for update
  to authenticated using (
    (
      select
        auth.uid ()
    ) = user_id
  )
with
  check (
    (
      select
        auth.uid ()
    ) = user_id
  );

create policy "Usuarios borran sus recetas" on recipes for DELETE to authenticated using (
  (
    select
      auth.uid ()
  ) = user_id
);

-- Políticas para ingredientes (basadas en la receta padre)

create policy "Acceso ingredientes" on ingredients for all to authenticated using (
  exists (
    select
      1
    from
      recipes
    where
      recipes.id = ingredients.recipe_id
      and recipes.user_id = (
        select
          auth.uid ()
      )
  )
)
with
  check (
    exists (
      select
        1
      from
        recipes
      where
        recipes.id = ingredients.recipe_id
        and recipes.user_id = (
          select
            auth.uid ()
        )
    )
  );

-- Políticas para pasos

create policy "Acceso pasos" on steps for all to authenticated using (
  exists (
    select
      1
    from
      recipes
    where
      recipes.id = steps.recipe_id
      and recipes.user_id = (
        select
          auth.uid ()
      )
  )
)
with
  check (
    exists (
      select
        1
      from
        recipes
      where
        recipes.id = steps.recipe_id
        and recipes.user_id = (
          select
            auth.uid ()
        )
    )
  );

