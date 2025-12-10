-- ==============================================================================
-- 1. CONFIGURACIÓN PARA GASTOS (EXPENSES)
-- ==============================================================================

-- Crear tabla expenses si no existe
create table if not exists expenses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  amount decimal(10, 2) not null check (amount > 0),
  description text not null check (char_length(description) >= 3),
  category text not null, 
  payment_method text,
  expense_date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Crear índices para performance
create index if not exists idx_expenses_user_id on expenses(user_id);
create index if not exists idx_expenses_date on expenses(expense_date);
create index if not exists idx_expenses_category on expenses(category);
create index if not exists idx_expenses_user_date on expenses(user_id, expense_date desc);

-- Habilitar seguridad (RLS)
alter table expenses enable row level security;

-- Políticas de seguridad (Solo el dueño puede ver/editar sus gastos)
create policy "Users can view own expenses" on expenses for select using (auth.uid() = user_id);
create policy "Users can insert own expenses" on expenses for insert with check (auth.uid() = user_id);
create policy "Users can update own expenses" on expenses for update using (auth.uid() = user_id);
create policy "Users can delete own expenses" on expenses for delete using (auth.uid() = user_id);


-- ==============================================================================
-- 2. CONFIGURACIÓN PARA PERFILES (Guardando Nombre/Foto de Perfil)
-- ==============================================================================

create table if not exists profiles (
  id uuid references auth.users(id) on delete cascade not null primary key,
  email text unique not null,
  full_name text check (char_length(full_name) >= 3),
  profile_photo_url text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Índices en profiles
create index if not exists idx_profiles_email on profiles(email);

-- Habilitar seguridad (RLS)
alter table profiles enable row level security;

-- Políticas de seguridad en profiles
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);

-- ==============================================================================
-- 3. FUNCIONES Y TRIGGERS PARA AUTO-CREACIÓN DE PERFILES
-- ==============================================================================

-- Función para auto-crear perfil al registrarse
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id, 
    new.email, 
    coalesce(new.raw_user_meta_data->>'full_name', 'User')
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Trigger que dispara la función anterior
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ==============================================================================
-- 4. COMENTARIOS Y DOCUMENTACIÓN
-- ==============================================================================

/*
TABLAS PRINCIPALES:
=====================

1. expenses (Tabla de Gastos)
   - Almacena todos los gastos de cada usuario
   - RLS: Cada usuario solo ve sus propios gastos
   - Validaciones:
     * amount > 0 (monto debe ser positivo)
     * description >= 3 caracteres (descripción mínima)
     * category: Requerido (Alimentación, Transporte, etc.)
   - Índices: user_id, expense_date, category, (user_id, expense_date)
   - ON DELETE CASCADE: Si el usuario se borra, se borran sus gastos

2. profiles (Tabla de Perfiles)
   - Almacena datos del usuario (nombre, email, foto)
   - Se crea automáticamente cuando se registra un usuario
   - RLS: Cada usuario solo ve/edita su propio perfil
   - Validaciones:
     * full_name >= 3 caracteres
     * email unique (no puede haber dos iguales)
   - profile_photo_url: Almacena la foto en base64 (data:image/jpeg;base64,...)
   - ON DELETE CASCADE: Si el usuario se borra, se borra su perfil

FLUJOS PRINCIPALES:
====================

1. Registro de Usuario:
   - Usuario envía email, password, full_name
   - Supabase Auth crea usuario en auth.users
   - Trigger on_auth_user_created se dispara automáticamente
   - Se crea registro en profiles con id, email y full_name

2. Crear Gasto:
   - Usuario autenticado envía amount, description, category, date
   - INSERT en expenses con user_id del usuario actual
   - RLS policy verifica que auth.uid() = user_id
   - Solo el propietario puede ver/editar/eliminar

3. Subir Foto de Perfil:
   - Usuario selecciona foto con ImagePicker (512x512, quality 75)
   - App convierte a base64
   - PATCH a profiles con profile_photo_url = "data:image/jpeg;base64,..."
   - Foto se almacena directamente en BD (no usa Storage bucket)

SEGURIDAD (RLS):
=================

Todas las tablas tienen Row Level Security habilitada:
- expenses: Usuario solo accede a sus propios gastos
- profiles: Usuario solo accede a su propio perfil

Esto garantiza que incluso si alguien obtiene el token,
no puede acceder a datos de otros usuarios.

EJECUCIÓN:
===========

Para ejecutar este script en Supabase:
1. Ve a SQL Editor
2. Copia todo el contenido de este archivo
3. Ejecuta (el script es idempotente con "if not exists")
4. Verifica que las tablas se crearon correctamente

*/
