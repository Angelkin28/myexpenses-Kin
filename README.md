# MyExpenses - Aplicación de Gestión de Gastos

![Flutter](https://img.shields.io/badge/Flutter-v3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-v3.9.2-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

Una aplicación móvil moderna y elegante para gestionar tus gastos personales, construida con Flutter y Supabase.

## 📱 Capturas de Pantalla

### Pantalla Principal
- **Home Screen**: Visualiza tus gastos organizados por fecha con resúmenes del día y del mes
- **Animaciones Lottie**: Estados vacíos y carga con animaciones fluidas
- **Búsqueda y Filtros**: Busca gastos con debounce de 500ms y filtra por categorías y fechas

### Gestión de Gastos
- **Agregar/Editar Gastos**: Formulario intuitivo con validación en tiempo real
- **Categorías**: 7 categorías predefinidas (Alimentación, Transporte, Entretenimiento, Salud, Servicios, Educación, Otros)
- **Detalles**: Vista detallada de cada gasto con opción de editar o eliminar

### Perfil de Usuario
- **Foto de Perfil**: Sube y actualiza tu foto de perfil almacenada en Supabase Storage
- **Información de Cuenta**: Visualiza tu email y datos de usuario
- **Logout**: Cierra sesión de forma segura

## 🚀 Características

### Funcionalidades Principales
- ✅ **Autenticación completa**: Registro, login y verificación por código
- ✅ **Gestión de gastos**: Crear, leer, actualizar y eliminar gastos (CRUD completo)
- ✅ **Categorización**: 7 categorías predefinidas con iconos y colores únicos
- ✅ **Filtros avanzados**: Por categoría, rango de fechas y búsqueda de texto
- ✅ **Resúmenes automáticos**: Totales del día y del mes actualizados en tiempo real
- ✅ **Perfil de usuario**: Foto de perfil almacenada en Supabase Storage
- ✅ **Formato de moneda**: Peso mexicano ($) con formato correcto
- ✅ **Validaciones**: Monto > 0 y descripción >= 3 caracteres

### Tecnologías y Arquitectura
- 🏗️ **Arquitectura limpia**: Feature-first con separación de capas
- 🔐 **Row Level Security (RLS)**: Cada usuario solo accede a sus propios datos
- 🎨 **Material Design**: UI moderna y responsive
- 🔄 **State Management**: Provider con ChangeNotifier
- 🌐 **REST API**: Integración con Supabase vía Dio
- 📦 **Local Storage**: Tokens guardados con SharedPreferences

## 🛠️ Instalación

### Prerequisitos

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio / Xcode (para compilar en Android/iOS)
- Cuenta de Supabase (gratuita)

### Paso 1: Clonar el repositorio

```bash
git clone https://github.com/Angelkin28/myexpenses-Kin.git
cd myexpenses-Kin/myexpenses_app
```

### Paso 2: Instalar dependencias

```bash
flutter pub get
```

### Paso 3: Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Ejecuta el script SQL para crear las tablas:

```sql
-- Ver archivo: db_schema.sql en la raíz del proyecto
```

3. Crea un bucket de Storage llamado `profile-photos` y márcalo como público
4. Ejecuta el script adicional para perfiles:

```sql
-- Ver archivo: supabase_profile_setup.sql
```

### Paso 4: Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto con tus credenciales de Supabase:
    ```env
    SUPABASE_URL=https://tu-proyecto.supabase.co
    SUPABASE_KEY=tu-anon-key
    ```

3.  **Instalar Dependencias:**
    ```bash
    flutter pub get
    ```

4.  **Ejecutar:**
    ```bash
    flutter run
    ```

## 🗄️ Base de Datos (Supabase)

Ejecuta el siguiente script SQL para configurar la tabla y políticas:

```sql
create table expenses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) not null,
  amount decimal not null,
  description text,
  category text,
  payment_method text,
  expense_date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table expenses enable row level security;

create policy "Users can view own expenses" on expenses for select using (auth.uid() = user_id);
create policy "Users can insert own expenses" on expenses for insert with check (auth.uid() = user_id);
create policy "Users can update own expenses" on expenses for update using (auth.uid() = user_id);
create policy "Users can delete own expenses" on expenses for delete using (auth.uid() = user_id);
```

## ✅ Funcionalidades Implementadas
- [x] Autenticación con Email/Password (Supabase Auth).
- [x] CRUD de Gastos (Supabase DB).
- [x] RLS (Row Level Security) para privacidad de datos.
- [x] Filtros locales (Búsqueda, Categoría, Fecha).
- [x] Agrupación por fechas.
- [x] Animaciones (Lottie & Transiciones).
- [x] Arquitectura Feature-first + Provider.
