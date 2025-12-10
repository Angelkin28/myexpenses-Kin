-- ==============================================================================
-- SCRIPTS DE LIMPIEZA DE DATOS PARA DEVELOPMENT
-- ==============================================================================
-- 
-- ⚠️  ADVERTENCIA: ESTOS COMANDOS ELIMINAN DATOS PERMANENTEMENTE
-- Solo usar en desarrollo/testing, NUNCA en producción
-- 
-- ==============================================================================

-- ==============================================================================
-- OPCIÓN 1: LIMPIAR TODAS LAS TABLAS (RECOMENDADO PARA TESTING)
-- ==============================================================================

-- Limpiar tabla de gastos (expenses)
-- Esto elimina todos los gastos de todos los usuarios
TRUNCATE TABLE expenses CASCADE;

-- Limpiar tabla de perfiles (profiles)
-- Esto elimina todos los perfiles
TRUNCATE TABLE profiles CASCADE;

-- Nota: Los usuarios en auth.users NO se eliminarán con TRUNCATE CASCADE
-- porque no tienen foreign key hacia las tablas públicas.
-- Para eliminarlos, ver OPCIÓN 2

-- ==============================================================================
-- OPCIÓN 2: ELIMINAR UN USUARIO ESPECÍFICO Y SUS DATOS
-- ==============================================================================

-- Para eliminar un usuario específico (reemplaza 'user-id-aqui' con el UUID real):
-- 
-- DELETE FROM expenses WHERE user_id = 'user-id-aqui';
-- DELETE FROM profiles WHERE id = 'user-id-aqui';
-- 
-- NOTA: Para eliminar el usuario de auth.users, usa la interfaz de Supabase
-- o el endpoint de admin API (como hace la app)

-- Ejemplo con email (requiere buscar el ID primero):
-- DELETE FROM expenses WHERE user_id = (
--   SELECT id FROM auth.users WHERE email = 'user@example.com'
-- );
-- DELETE FROM profiles WHERE id = (
--   SELECT id FROM auth.users WHERE email = 'user@example.com'
-- );

-- ==============================================================================
-- OPCIÓN 3: ELIMINAR GASTOS DE UN USUARIO ESPECÍFICO (MANTENER PERFIL)
-- ==============================================================================

-- Para eliminar solo los gastos de un usuario (reemplaza 'user-id-aqui'):
-- 
-- DELETE FROM expenses WHERE user_id = 'user-id-aqui';

-- ==============================================================================
-- OPCIÓN 4: LIMPIAR SOLO GASTOS MÁS ANTIGUOS QUE UNA FECHA
-- ==============================================================================

-- Eliminar todos los gastos antes de una fecha específica:
-- 
-- DELETE FROM expenses WHERE expense_date < '2024-12-01';

-- ==============================================================================
-- OPCIÓN 5: LIMPIAR GASTOS POR CATEGORÍA
-- ==============================================================================

-- Eliminar todos los gastos de una categoría específica:
-- 
-- DELETE FROM expenses WHERE category = 'entertainment';
-- 
-- Categorías disponibles:
-- - food (Alimentación)
-- - transport (Transporte)
-- - entertainment (Entretenimiento)
-- - health (Salud)
-- - services (Servicios)
-- - education (Educación)
-- - others (Otros)

-- ==============================================================================
-- OPCIÓN 6: VER ESTADÍSTICAS ANTES DE LIMPIAR
-- ==============================================================================

-- Contar total de usuarios registrados:
-- 
-- SELECT COUNT(*) as total_usuarios FROM profiles;

-- Contar total de gastos:
-- 
-- SELECT COUNT(*) as total_gastos FROM expenses;

-- Ver gastos por usuario:
-- 
-- SELECT 
--   p.full_name,
--   p.email,
--   COUNT(e.id) as total_gastos,
--   COALESCE(SUM(e.amount), 0) as total_gastado
-- FROM profiles p
-- LEFT JOIN expenses e ON p.id = e.user_id
-- GROUP BY p.id, p.full_name, p.email
-- ORDER BY total_gastado DESC;

-- Ver gastos por categoría:
-- 
-- SELECT 
--   category,
--   COUNT(*) as cantidad,
--   SUM(amount) as total
-- FROM expenses
-- GROUP BY category
-- ORDER BY total DESC;

-- Ver gastos por rango de fechas:
-- 
-- SELECT 
--   DATE_TRUNC('month', expense_date) as mes,
--   COUNT(*) as cantidad,
--   SUM(amount) as total
-- FROM expenses
-- GROUP BY DATE_TRUNC('month', expense_date)
-- ORDER BY mes DESC;

-- ==============================================================================
-- OPCIÓN 7: RESETEAR SEQUENCES (Si usas ID autoincrementales)
-- ==============================================================================

-- Nota: El proyecto usa UUIDs, así que esto NO es necesario.
-- Pero si en futuro usas serial/bigserial:
-- 
-- ALTER SEQUENCE nombre_sequence RESTART WITH 1;

-- ==============================================================================
-- SCRIPT COMPLETO PARA LIMPIAR TODO (DESARROLLO SOLAMENTE)
-- ==============================================================================

/*
Para limpiar COMPLETAMENTE tu base de datos de desarrollo y empezar de cero:

1. Ve a SQL Editor en Supabase
2. Copia y pega SOLO ESTAS LÍNEAS (no el comentario):

    -- Desactivar RLS temporalmente (si es necesario)
    ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
    ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
    
    -- Limpiar todos los datos
    TRUNCATE TABLE expenses CASCADE;
    TRUNCATE TABLE profiles CASCADE;
    
    -- Reactivar RLS
    ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

3. Ejecuta
4. Listo, todas las tablas están vacías pero la estructura se mantiene

Para eliminar usuarios de auth.users:
- Ve a Authentication > Users en Supabase Dashboard
- Selecciona el usuario
- Click en "Delete user" (aparece un modal de confirmación)

*/

-- ==============================================================================
-- INFORMACIÓN ÚTIL
-- ==============================================================================

/*
IMPORTANTE: Diferencia entre TRUNCATE y DELETE
==============================================

DELETE FROM table;
- Más lento pero seguro
- Respeta las constraints
- Genera logs de eliminación
- Puede ser reversible con transacciones

TRUNCATE TABLE table CASCADE;
- Muy rápido
- Resetea el SERIAL/IDENTITY (no aplica aquí, usamos UUIDs)
- Más eficiente en tablas grandes
- No genera logs individuales

Para desarrollo, TRUNCATE es mejor.
Para producción, usa DELETE WITH caution.

CASCADA
=======
CASCADE en TRUNCATE significa:
- Si la tabla A referencia a la B
- Y haces TRUNCATE TABLE A CASCADE
- También se truncan las tablas que referencian A

En nuestro caso:
- expenses referencia profiles a través de user_id? NO
- expenses referencia auth.users? SÍ (pero no podemos truncate auth.users)
- profiles referencia auth.users? SÍ (pero no podemos truncate auth.users)

Entonces CASCADE solo limpia lo que podemos limpiar.
*/
