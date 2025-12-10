# MyExpenses - Gestor de Gastos Personales

Aplicación Flutter para gestión de gastos diarios, desarrollada como prueba técnica.

## 📱 Screenshots
(Agrega tus capturas aquí)

## 🛠 Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone <tu-repo>
    cd myexpenses-app
    ```

2.  **Configurar Variables de Entorno:**
    Crea un archivo `.env` en la raíz con tus credenciales de Supabase:
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
