-- SQL Script para configurar la tabla de perfiles y el bucket de fotos en Supabase

-- 1. Crear tabla de perfiles (si no existe)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  profile_photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Habilitar RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Políticas de seguridad para la tabla profiles
-- Los usuarios solo pueden ver y editar su propio perfil
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 4. Función para crear perfil automáticamente cuando se registra un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Trigger para ejecutar la función cuando se crea un nuevo usuario
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 6. Crear bucket de storage para fotos de perfil (ejecutar en la UI de Supabase Storage)
-- Ve a Storage > Create Bucket
-- Nombre: profile-photos
-- Public: YES (para que las fotos sean accesibles públicamente)

-- 7. Políticas de Storage para el bucket profile-photos
-- Estas se configuran en la UI de Supabase en Storage > profile-photos > Policies

-- Política para permitir que usuarios autenticados suban fotos
-- CREATE POLICY "Users can upload own profile photo"
-- ON storage.objects FOR INSERT
-- TO authenticated
-- WITH CHECK (bucket_id = 'profile-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Política para permitir lectura pública de fotos
-- CREATE POLICY "Public can view profile photos"
-- ON storage.objects FOR SELECT
-- TO public
-- USING (bucket_id = 'profile-photos');

-- Política para permitir que usuarios actualicen su propia foto
-- CREATE POLICY "Users can update own profile photo"
-- ON storage.objects FOR UPDATE
-- TO authenticated
-- USING (bucket_id = 'profile-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Política para permitir que usuarios eliminen su propia foto
-- CREATE POLICY "Users can delete own profile photo"
-- ON storage.objects FOR DELETE
-- TO authenticated
-- USING (bucket_id = 'profile-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

-- 8. Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);

-- INSTRUCCIONES ADICIONALES:
-- 
-- Para crear el bucket "profile-photos":
-- 1. Ve a tu proyecto de Supabase
-- 2. Navega a Storage en el menú lateral
-- 3. Haz clic en "Create a new bucket"
-- 4. Nombre: profile-photos
-- 5. Marca como "Public bucket" para permitir acceso público de lectura
-- 6. Haz clic en Create
--
-- Configurar políticas de Storage (después de crear el bucket):
-- 1. Ve a Storage > profile-photos
-- 2. Haz clic en "Policies"
-- 3. Crea las siguientes políticas:
--    a) INSERT policy: Permite a usuarios autenticados subir archivos
--    b) SELECT policy: Permite a todos leer archivos (público)
--    c) UPDATE policy: Permite a usuarios autenticados actualizar sus propios archivos
--    d) DELETE policy: Permite a usuarios autenticados eliminar sus propios archivos
