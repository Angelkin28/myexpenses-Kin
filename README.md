# MyExpenses - Aplicación de Gestión de Gastos

![Flutter](https://img.shields.io/badge/Flutter-v3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-v3.9.2-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green)
![Provider](https://img.shields.io/badge/Provider-v6.1.2-yellow)
![License](https://img.shields.io/badge/License-MIT-yellow)

Una aplicación móvil moderna y elegante para gestionar tus gastos personales, construida con **Flutter 3.9.2** y **Supabase**. Incluye autenticación, CRUD completo de gastos, filtros avanzados, perfil de usuario con foto y animaciones fluidas.

---

## 📋 Tabla de Contenidos

1. [Características](#características)
2. [Arquitectura](#arquitectura)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Base de Datos](#base-de-datos)
5. [Dependencias](#dependencias)
6. [Instalación](#instalación)
7. [Configuración](#configuración)
8. [Restricciones Implementadas](#restricciones-implementadas)
9. [Guía de Desarrollo](#guía-de-desarrollo)
10. [Resolución de Problemas](#resolución-de-problemas)

---

## 🚀 Características

### Funcionalidades Principales

- ✅ **Autenticación completa**: Registro, login y verificación por código (Supabase Auth)
- ✅ **CRUD de Gastos**: Crear, leer, actualizar y eliminar gastos
- ✅ **7 Categorías predefinidas**: Alimentación, Transporte, Entretenimiento, Salud, Servicios, Educación, Otros
- ✅ **Filtros avanzados**: 
  - Búsqueda por descripción (debounce 500ms)
  - Filtro por categoría
  - Filtro por rango de fechas
  - Filtros aplicados localmente sin peticiones adicionales
- ✅ **Resúmenes automáticos**: Totales del día y mes actualizados en tiempo real
- ✅ **Perfil de usuario**:
  - Foto de perfil con Image Picker
  - Almacenamiento en Supabase (base64)
  - Visualización de email y datos de usuario
- ✅ **Formato de moneda**: Peso mexicano ($) con formato correcto
- ✅ **Validaciones**: Monto > 0 y descripción >= 3 caracteres
- ✅ **Animaciones Lottie**: 
  - Splash screen con animación de carga
  - Estados vacíos con animaciones
  - Control de repetición y velocidad

### Tecnologías y Patrones

- 🏗️ **Arquitectura**: Feature-first con separación de capas
- 🔐 **Seguridad**: Row Level Security (RLS) en todas las tablas
- 🎨 **UI/UX**: Material Design 3 con Material You
- 🔄 **State Management**: Provider (ChangeNotifier) - sin StatefulWidget para estado
- 🌐 **Backend**: Supabase REST API con Dio
- 📦 **Storage**: SharedPreferences para tokens y datos locales
- 🎬 **Animaciones**: Lottie JSON con control granular

---

## 🏗️ Arquitectura

### Patrón de Arquitectura: Feature-First + Clean Architecture

```
lib/
├── main.dart                 # Punto de entrada
├── routes.dart              # Configuración de rutas (go_router)
├── core/                    # Código compartido
│   ├── constants/           # Constantes globales (categorías, colores)
│   ├── errors/              # Clases de error personalizadas
│   └── services/            # Servicios globales (DioClient, SupabaseService)
├── features/                # Características de negocio
│   ├── auth/               # Autenticación
│   │   ├── screens/        # Pantallas (SplashScreen, LoginScreen, RegisterScreen)
│   │   ├── providers/      # AuthProvider
│   │   └── repositories/   # AuthRepository
│   ├── expenses/           # Gestión de gastos
│   │   ├── screens/        # HomeScreen, ExpenseDetailScreen
│   │   ├── providers/      # ExpensesProvider, ExpenseFormProvider
│   │   ├── repositories/   # ExpenseRepository
│   │   ├── models/         # Expense, ExpenseCategory models
│   │   └── widgets/        # ExpenseCard, FilterBottomSheet, etc.
│   └── profile/            # Perfil de usuario
│       ├── screens/        # ProfileScreen
│       ├── providers/      # ProfileProvider
│       └── repositories/   # ProfileRepository
└── shared/                 # Código reutilizable
    └── widgets/            # LottieLoader, CustomButton, etc.
```

### Flujo de Datos

```
UI (Screen/Widget)
    ↓
Consumer<Provider> (escucha cambios)
    ↓
Provider (ChangeNotifier) - maneja estado
    ↓
Repository (acceso a datos)
    ↓
DioClient (HTTP requests a Supabase)
    ↓
Supabase REST API
    ↓
Base de Datos PostgreSQL
```

### State Management sin StatefulWidget

Se utiliza **Provider con ChangeNotifier** para todos los estados. `StatefulWidget` solo se usa para inicialización en `initState()` con `Future.microtask()`:

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ExpensesProvider>().loadExpenses();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpensesProvider>(
        builder: (context, provider, _) {
          // UI reactiva aquí
        },
      ),
    );
  }
}
```

---

## 📁 Estructura del Proyecto Detallada

### `lib/core/`

**Constantes:**
```dart
// core/constants/expense_categories.dart
enum ExpenseCategory {
  food,      // Alimentación (🍔)
  transport, // Transporte (🚗)
  entertainment, // Entretenimiento (🎬)
  health,    // Salud (⚕️)
  services,  // Servicios (🛠️)
  education, // Educación (📚)
  other      // Otros (📌)
}
```

**Servicios:**
- `DioClient`: Singleton que configura Dio con Supabase URL y headers
- `SupabaseService`: Inicializa y gestiona conexión con Supabase

### `lib/features/auth/`

**AuthProvider**: Maneja sesión de usuario
- `login(email, password)`: Autentica usuario
- `register(email, password)`: Registra nuevo usuario
- `logout()`: Cierra sesión
- `verifyOtp(email, otp)`: Verifica código OTP
- `currentUser`: Usuario autenticado actual

**Pantallas:**
- `SplashScreen`: Splash de 2 segundos con animación Lottie
- `LoginScreen`: Formulario de login con validación
- `RegisterScreen`: Formulario de registro
- `OtpVerificationScreen`: Verificación por OTP

### `lib/features/expenses/`

**ExpensesProvider**: Estado principal de gastos
- `loadExpenses()`: Carga todos los gastos del usuario
- `addExpense(Expense)`: Agrega nuevo gasto
- `updateExpense(Expense)`: Actualiza gasto existente
- `deleteExpense(String id)`: Elimina gasto
- `filterByCategory(String category)`: Filtra por categoría
- `searchByDescription(String query)`: Busca por descripción (debounce 500ms)
- `filterByDateRange(DateTime start, DateTime end)`: Filtra por fechas
- `getFilteredExpenses()`: Retorna gastos filtrados
- `getDailyTotal()`: Suma del día actual
- `getMonthlyTotal()`: Suma del mes actual
- `hasSearch`: Getter que verifica si hay búsqueda activa

**ExpenseFormProvider**: Maneja estado del formulario
- `setAmount(double)`: Establece monto
- `setDescription(String)`: Establece descripción
- `setCategory(ExpenseCategory)`: Establece categoría
- `setDate(DateTime)`: Establece fecha
- `validateForm()`: Valida antes de guardar

**Modelos:**
```dart
class Expense {
  final String id;
  final String userId;
  final double amount;      // Validación: > 0
  final String description; // Validación: >= 3 caracteres
  final String category;
  final DateTime expenseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Widgets:**
- `ExpenseCard`: Tarjeta de gasto con categoría y monto
- `FilterBottomSheet`: Hoja modal con filtros (sin overflow)
- `EmptyState`: Estado vacío con animación Lottie
- `ExpenseSummary`: Resumen del día/mes

### `lib/features/profile/`

**ProfileProvider**: Gestiona perfil de usuario
- `loadProfile()`: Carga datos del perfil desde base de datos
- `uploadProfilePhoto(File imageFile, String userId)`: 
  - Comprime imagen (512x512, quality 75)
  - Convierte a base64
  - Almacena en tabla `profiles` (sin Storage bucket)
  - Retorna boolean de éxito/fallo
- `profilePhotoUrl`: URL/base64 de foto actual

**ProfileScreen**: Pantalla de perfil
- Image Picker integrado
- Selección de foto con compresión automática
- Visualización de foto con `Image.memory()` y base64 decoding
- Información de usuario (email, ID)
- Botón de logout con confirmación
- SnackBar con feedback de carga/error

### `lib/shared/widgets/`

**LottieLoader**: Widget reutilizable de animación
```dart
LottieLoader(
  assetName: 'loading.json',
  height: 200,
  width: 200,
  repeat: true,    // true = loop infinito
  playOnce: false, // true = AnimationController (una sola vez)
  fit: BoxFit.contain,
)
```

**Parámetros:**
- `assetName`: Nombre del archivo JSON en `assets/lottie/`
- `height`, `width`: Dimensiones de la animación
- `repeat`: Si debe repetirse infinitamente
- `playOnce`: Si debe usar AnimationController para una sola ejecución
- `fallback`: Icon mostrado si falla la carga

---

## 🗄️ Base de Datos

### Tablas

#### 1. `auth.users` (Supabase Auth - Automática)
Gestiona autenticación y usuarios.

#### 2. `expenses`

```sql
create table expenses (
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

-- Índices para performance
create index idx_expenses_user_id on expenses(user_id);
create index idx_expenses_date on expenses(expense_date);
create index idx_expenses_category on expenses(category);

-- Row Level Security
alter table expenses enable row level security;

create policy "Users can view own expenses" 
  on expenses for select using (auth.uid() = user_id);

create policy "Users can insert own expenses" 
  on expenses for insert with check (auth.uid() = user_id);

create policy "Users can update own expenses" 
  on expenses for update using (auth.uid() = user_id);

create policy "Users can delete own expenses" 
  on expenses for delete using (auth.uid() = user_id);
```

#### 3. `profiles`

```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  profile_photo_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trigger para crear perfil automáticamente
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Row Level Security
alter table profiles enable row level security;

create policy "Users can view own profile" 
  on profiles for select using (auth.uid() = id);

create policy "Users can update own profile" 
  on profiles for update using (auth.uid() = id);

create policy "Users can insert own profile" 
  on profiles for insert with check (auth.uid() = id);
```

### Almacenamiento de Fotos de Perfil

Las fotos se almacenan como **base64 encoded strings** directamente en la columna `profile_photo_url`:

```
data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQ...
```

**Ventajas:**
- ✅ Sin necesidad de configurar Storage bucket
- ✅ Transacciones ACID garantizadas
- ✅ Sincronización simplificada
- ✅ Fotos comprimidas automáticamente (512x512, quality 75)

**Proceso:**
1. Usuario selecciona foto con ImagePicker
2. App comprime a 512x512px y quality 75
3. Convierte a base64 con prefijo `data:image/jpeg;base64,`
4. Envía PATCH a `/rest/v1/profiles?id=eq.$userId` con base64
5. Base de datos almacena completa
6. En UI: `Image.memory(base64Decode(photoUrl.split(',')[1]))`

---

## 📦 Dependencias

### Versiones Principales

```yaml
flutter: ">=3.9.2"
dart: ">=3.9.2 <4.0.0"

dependencies:
  # Frontend
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State Management
  provider: ^6.1.2

  # Autenticación & Backend
  supabase_flutter: ^2.10.5
  dio: ^5.7.0

  # Navegación
  go_router: ^14.6.0

  # Storage Local
  shared_preferences: ^2.5.4

  # Utilidades
  intl: ^0.19.0
  flutter_dotenv: ^5.2.1

  # Animaciones
  lottie: ^3.1.3

  # Media
  image_picker: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 🛠️ Instalación

### Requisitos Previos

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio / Xcode (para compilar)
- Cuenta de Supabase (gratuita en https://supabase.com)
- Git instalado

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/Angelkin28/myexpenses-Kin.git
cd myexpenses-Kin/myexpenses_app
```

### Paso 2: Instalar Dependencias

```bash
flutter pub get
```

### Paso 3: Configurar Supabase

1. **Crear proyecto en Supabase:**
   - Ve a https://supabase.com
   - Crea nuevo proyecto
   - Copia tu `Project URL` y `Anon Key`

2. **Ejecutar script SQL:**
   - Ve a SQL Editor en Supabase
   - Copia el contenido de `db_schema.sql`
   - Ejecuta el script
   - Repite con `supabase_profile_setup.sql`

3. **Crear bucket de Storage (opcional):**
   - Ve a Storage → New Bucket
   - Nombre: `profile-photos`
   - Marca como "Public"
   - Crea carpeta `profile-photos/` dentro

### Paso 4: Configurar Variables de Entorno

Crea archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
```

Carga en `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  runApp(const MyApp());
}
```

### Paso 5: Ejecutar la App

```bash
# En emulador/dispositivo
flutter run

# Para debugging con output detallado
flutter run -v

# Para generar APK
flutter build apk --release

# Para generar iOS
flutter build ios --release
```

---

## ⚙️ Configuración Avanzada

### Configurar go_router

```dart
// lib/routes.dart
final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'expense/:id',
          name: 'expenseDetail',
          builder: (context, state) {
            final expenseId = state.pathParameters['id']!;
            return ExpenseDetailScreen(expenseId: expenseId);
          },
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null && state.matchedLocation != '/login' && state.matchedLocation != '/register') {
      return '/login';
    }
    if (user != null && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
      return '/home';
    }
    return null;
  },
);
```

### Configurar Dio para Supabase

```dart
// core/services/dio_client.dart
class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() {
    return _instance;
  }

  late Dio _dio;

  DioClient._internal() {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    _dio = Dio(
      BaseOptions(
        baseUrl: '$supabaseUrl/rest/v1',
        headers: {
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
          'apikey': supabaseKey,
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('Dio error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {required dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {required dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

---

## 📋 Restricciones Implementadas

El proyecto cumple con **8 restricciones de código** específicas:

### 1. ✅ NO StatefulWidget para Estado de la Aplicación
- StatefulWidget solo se usa para inicialización (`initState`)
- Todo estado se maneja con **Provider + ChangeNotifier**
- UI se actualiza con **Consumer** y **.watch()**

```dart
// ✅ CORRECTO: StateNotifier para estado
class ExpensesProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  
  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }
}

// UI actualiza reactivamente
Consumer<ExpensesProvider>(
  builder: (context, provider, _) => ListView(
    children: provider.expenses.map((e) => ExpenseCard(e)).toList(),
  ),
)
```

### 2. ✅ Validación de Monto > 0
```dart
// En modelo y base de datos
check (amount > 0)

// En form provider
if (amount <= 0) {
  throw ValidationException('El monto debe ser mayor a 0');
}
```

### 3. ✅ Validación de Descripción >= 3 Caracteres
```dart
// En modelo y base de datos
check (char_length(description) >= 3)

// En form provider
if (description.trim().length < 3) {
  throw ValidationException('Mínimo 3 caracteres');
}
```

### 4. ✅ Categorías Hardcodeadas
```dart
enum ExpenseCategory {
  food,           // Alimentación
  transport,      // Transporte
  entertainment,  // Entretenimiento
  health,         // Salud
  services,       // Servicios
  education,      // Educación
  other           // Otros
}
```

### 5. ✅ Formato de Moneda Mexicana ($)
```dart
// Usando intl.dart
import 'package:intl/intl.dart';

String formattedAmount = NumberFormat.currency(
  locale: 'es_MX',
  symbol: '\$',
  decimalDigits: 2,
).format(amount);
// Resultado: "$1,234.56"
```

### 6. ✅ Filtros Locales (Sin Peticiones Adicionales)
```dart
// Todos los filtros se aplican en memoria
List<Expense> getFilteredExpenses() {
  return _expenses
    .where((e) => _searchQuery.isEmpty || 
      e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
    .where((e) => _selectedCategory.isEmpty || e.category == _selectedCategory)
    .where((e) => e.expenseDate.isAfter(_startDate) && 
      e.expenseDate.isBefore(_endDate))
    .toList();
}
```

### 7. ✅ Debounce 500ms en Búsqueda
```dart
// En ExpensesProvider
Timer? _searchDebounce;

void searchByDescription(String query) {
  _searchDebounce?.cancel();
  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
    _searchQuery = query;
    notifyListeners();
  });
}
```

### 8. ✅ Selección de Fecha con showDatePicker()
```dart
// En ExpenseFormProvider
Future<void> selectDate(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );
  
  if (picked != null && picked != _selectedDate) {
    _selectedDate = picked;
    notifyListeners();
  }
}
```

### 9. ✅ Recálculo Automático de Resúmenes
```dart
// Se recalcula automáticamente en cada cambio
void addExpense(Expense expense) {
  _expenses.add(expense);
  _recalculateSummaries(); // Actualiza totales
  notifyListeners();
}

void _recalculateSummaries() {
  _dailyTotal = _calculateDailyTotal();
  _monthlyTotal = _calculateMonthlyTotal();
}
```

---

## 👨‍💻 Guía de Desarrollo

### Agregar Nueva Funcionalidad

**Ejemplo: Agregar nueva categoría**

1. **Actualizar enum:**
   ```dart
   // core/constants/expense_categories.dart
   enum ExpenseCategory {
     // ... existing
     newCategory,
   }
   ```

2. **Actualizar UI (categorías picker):**
   ```dart
   // widgets que muestran categorías
   DropdownButton(
     items: ExpenseCategory.values.map((cat) {
       return DropdownMenuItem(
         value: cat,
         child: Text(categoryLabel(cat)),
       );
     }).toList(),
   )
   ```

3. **Opcionalmente: Agregar constantes visuales:**
   ```dart
   Map<ExpenseCategory, String> categoryLabels = {
     ExpenseCategory.newCategory: 'Nueva Categoría',
   };
   
   Map<ExpenseCategory, IconData> categoryIcons = {
     ExpenseCategory.newCategory: Icons.icon_here,
   };
   ```

### Agregar Nuevo Provider

```dart
// lib/features/myfeature/providers/my_provider.dart
class MyProvider extends ChangeNotifier {
  // Estado
  String _state = '';
  
  String get state => _state;
  
  // Métodos
  void updateState(String newState) {
    _state = newState;
    notifyListeners();
  }
}

// Registrar en main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
  child: const MyApp(),
)

// Usar en UI
Consumer<MyProvider>(
  builder: (context, provider, _) {
    return Text(provider.state);
  },
)
```

### Manejar Errores de API

```dart
// En repository
Future<List<Expense>> fetchExpenses() async {
  try {
    final response = await _dioClient.get('/expenses');
    // Procesar response
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      // Token expirado
      throw UnauthorizedException('Sesión expirada');
    } else if (e.response?.statusCode == 403) {
      // Acceso denegado
      throw ForbiddenException('Acceso denegado');
    } else {
      throw ServerException(e.message ?? 'Error desconocido');
    }
  }
}

// En provider
void loadExpenses() async {
  try {
    _isLoading = true;
    notifyListeners();
    
    _expenses = await _repository.fetchExpenses();
  } on UnauthorizedException {
    // Redirigir a login
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Debugging

**Print statements:**
```dart
// En ProfileProvider
Future<bool> uploadProfilePhoto(File imageFile, String userId) async {
  try {
    print('📸 Iniciando carga de foto para usuario: $userId');
    print('📦 Tamaño archivo: ${imageFile.lengthSync()} bytes');
    
    // ... código
    
    print('✅ Foto cargada exitosamente');
    return true;
  } catch (e) {
    print('❌ Error al cargar foto: $e');
    return false;
  }
}
```

**Verificar estado en UI:**
```dart
// Agregar botón de debug en Drawer
ListTile(
  title: const Text('Debug Info'),
  onTap: () {
    final expenses = context.read<ExpensesProvider>();
    print('Total gastos: ${expenses.expenses.length}');
    print('Total mes: ${expenses.monthlyTotal}');
  },
)
```

---

## 🐛 Resolución de Problemas

### Problema: "Failed to upload photo"

**Síntomas:** La foto no se guarda después de seleccionar.

**Causa:** Error en codificación base64 o fallo de conexión a Supabase.

**Solución:**
1. Verifica que el usuario esté autenticado: `AuthProvider().currentUser != null`
2. Comprueba que tienes conexión: `flutter run -v` y busca errores de red
3. Verifica credenciales de Supabase en `.env`
4. Comprueba que la tabla `profiles` existe y tiene RLS correcta
5. Revisa console logs: busca "Error al cargar foto" en ProfileProvider

### Problema: Animación Lottie no aparece

**Síntomas:** Pantalla en blanco donde debería haber animación.

**Causa:** 
- Archivo JSON no existe
- Ruta incorrecta
- Error en parsing del JSON

**Solución:**
1. Verifica que el archivo existe en `assets/lottie/`
2. Verifica pubspec.yaml tiene entrada de assets:
   ```yaml
   flutter:
     assets:
       - assets/lottie/
   ```
3. Ejecuta `flutter pub get` y `flutter clean && flutter run`
4. Comprueba nombre exacto: `loading.json`, `no_result_found.json`

### Problema: Filtros no aparecen en bottom sheet

**Síntomas:** Bottom sheet se ve vacía o cortada.

**Causa:** Overflow por altura fija sin scroll.

**Solución:** ✅ Ya corregido - usa `SingleChildScrollView` con `mainAxisSize: MainAxisSize.min`:
```dart
SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Filtros aquí
      const SizedBox(height: 24),
      ElevatedButton(onPressed: applyFilters, child: Text('Aplicar')),
    ],
  ),
)
```

### Problema: App cicla infinitamente cargando

**Síntomas:** Spinner de carga nunca desaparece.

**Causa:** `WidgetsBinding.addPostFrameCallback()` en `build()` causa loops infinitos.

**Solución:** ✅ Ya corregido - usa `initState()`:
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    context.read<ExpensesProvider>().loadExpenses();
  });
}

@override
Widget build(BuildContext context) {
  return Consumer<ExpensesProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) return CircularProgressIndicator();
      return ListView(...);
    },
  );
}
```

### Problema: "Unauthorized" o errores 401

**Síntomas:** App muestra error cada vez que intenta cargar datos.

**Causa:** Token expirado o credenciales inválidas en Supabase.

**Solución:**
1. Verifica token guardado: `SharedPreferences.getInstance().getString('token')`
2. Comprueba que AuthProvider refrescaToken cuando expira
3. Verifica que RLS policies no sean demasiado restrictivas
4. Cierra sesión y vuelve a iniciar: debería obtener token nuevo

### Problema: Foto no se muestra después de subir

**Síntomas:** Upload exitoso pero foto blanca/vacía.

**Causa:** `Image.memory()` no decodifica correctamente el base64.

**Solución:** Verifica que el string base64 contiene el prefijo correcto:
```dart
// Debe ser así
String photoUrl = 'data:image/jpeg;base64,/9j/4AAQSkZJRg...';

// Decodificar correctamente
final base64String = photoUrl.split(',')[1]; // Quita prefijo
Image.memory(
  base64Decode(base64String),
  fit: BoxFit.cover,
)
```

---

## 📊 Estadísticas del Proyecto

- **Líneas de código Dart**: ~3,500+
- **Pantallas**: 7 (Splash, Login, Register, OTP, Home, Expense Detail, Profile)
- **Providers**: 4 (Auth, Expenses, ExpenseForm, Profile)
- **Widgets personalizados**: 8+
- **Archivos de assets**: 2 (loading.json, no_result_found.json)
- **Tablas en BD**: 3 (auth.users, expenses, profiles)
- **Políticas RLS**: 12 (security-first)
- **Animaciones**: Lottie + Transiciones Flutter

---

## 📝 Licencia

MIT License - Ver archivo LICENSE para detalles.

---

## 👤 Autor

**Ángel Kin** - [GitHub](https://github.com/Angelkin28)

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios mayores:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📧 Soporte

Para reportar bugs o solicitar features, abre un [Issue](https://github.com/Angelkin28/myexpenses-Kin/issues).

---

**Última actualización:** Diciembre 2025
**Versión:** 1.0.0
**Estado:** ✅ Producción
