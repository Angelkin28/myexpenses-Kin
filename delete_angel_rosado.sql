-- ==============================================================================
-- SQL PARA ELIMINAR USUARIO: angel.rosado.kin@gmail.com
-- ==============================================================================

-- UUID del usuario: 96dc7303-2f54-4922-a8ba-099ca158be00

-- OPCIÓN 1: ELIMINAR TODO (Usuario, Gastos y Perfil)
-- =====================================================

-- Paso 1: Ver cuántos gastos tiene antes de eliminar
SELECT 
  COUNT(*) as total_gastos,
  COALESCE(SUM(amount), 0) as total_gastado
FROM expenses 
WHERE user_id = '96dc7303-2f54-4922-a8ba-099ca158be00';

-- Paso 2: Eliminar todos los gastos del usuario
DELETE FROM expenses 
WHERE user_id = '96dc7303-2f54-4922-a8ba-099ca158be00';

-- Paso 3: Eliminar el perfil del usuario
DELETE FROM profiles 
WHERE id = '96dc7303-2f54-4922-a8ba-099ca158be00';

-- Nota: Para eliminar el usuario de auth.users, debes:
-- - Usar Supabase Dashboard (Authentication > Users > Delete)
-- - O usar la app (ProfileScreen > Delete Account)
-- - O usar el endpoint de admin API (que hace la app automáticamente)

-- ==============================================================================
-- OPCIÓN 2: SOLO VER DATOS SIN ELIMINAR (PARA VERIFICAR)
-- ==============================================================================

-- Ver perfil del usuario
SELECT * FROM profiles 
WHERE id = '96dc7303-2f54-4922-a8ba-099ca158be00';

-- Ver todos los gastos del usuario
SELECT * FROM expenses 
WHERE user_id = '96dc7303-2f54-4922-a8ba-099ca158be00'
ORDER BY expense_date DESC;

-- Ver resumen de gastos por categoría
SELECT 
  category,
  COUNT(*) as cantidad,
  SUM(amount) as total
FROM expenses 
WHERE user_id = '96dc7303-2f54-4922-a8ba-099ca158be00'
GROUP BY category
ORDER BY total DESC;

-- ==============================================================================
-- OPCIÓN 3: ELIMINAR SOLO GASTOS (MANTENER PERFIL Y USUARIO)
-- ==============================================================================

-- DELETE FROM expenses 
-- WHERE user_id = '96dc7303-2f54-4922-a8ba-099ca158be00';

-- ==============================================================================
-- INFORMACIÓN DEL USUARIO
-- ==============================================================================
/*

Email: angel.rosado.kin@gmail.com
UUID:  96dc7303-2f54-4922-a8ba-099ca158be00

PASOS RECOMENDADOS:
1. Ejecuta primero la query de "Paso 1" para ver cuántos gastos tiene
2. Si estás seguro, ejecuta "Paso 2" para eliminar los gastos
3. Ejecuta "Paso 3" para eliminar el perfil
4. Ve a Supabase Dashboard > Authentication > Users y elimina el usuario manualmente
   (O usa la app: Profile > Delete Account)

TODO ESTO ES IRREVERSIBLE. Asegúrate antes de ejecutar.

*/
