<!-- # Guía: Eliminar Usuarios desde Supabase Dashboard -->

# Eliminar Usuarios desde Supabase Authentication

## 📍 Ubicación en el Dashboard

1. **Ve a tu proyecto en Supabase**: https://supabase.com/dashboard
2. **Selecciona tu proyecto**: `myexpenses_app`
3. **Ve a la sección**: `Authentication` (en el menú izquierdo)
4. **Click en**: `Users` (debajo de "MANAGE")

## 🗑️ Eliminar UN usuario

### Pasos:
1. En la tabla de usuarios, **busca el usuario** que quieres eliminar por:
   - Email
   - UID (User ID)
   - Display name

2. **Haz click en la fila del usuario** para seleccionarlo

3. **Click en el botón "..." (tres puntos)** o busca una opción de "Delete"

4. **Confirma la eliminación** en el modal que aparece
   - ⚠️ ADVERTENCIA: "Deleting a user is irreversible"
   - ✅ Esto eliminará:
     - El usuario de `auth.users`
     - Todos sus gastos (por CASCADE)
     - Su perfil (por CASCADE)
     - Su foto (guardada en profiles)

## 🗑️ Eliminar MÚLTIPLES usuarios

### Pasos (como se ve en tu screenshot):
1. **Abre la tabla Users** en Authentication
2. **Selecciona múltiples usuarios** con los checkboxes (✓) que aparecen a la izquierda
3. **Verás un botón**: "Delete 2 users" (o el número que seleccionaste)
4. **Click en el botón "Delete"**
5. **Confirma en el modal de confirmación**

### En tu caso (del screenshot):
- ✓ angel.rosado.kin@gmail.com (96dc7303-2f54-4922-a8ba-099ca158be00)
- ✓ won.dorado.mid@gmail.com (0395fect-d793-403a-a65a-f3a9c797684)

**Ambos serían eliminados junto con:**
- Todos sus gastos
- Sus perfiles
- Sus fotos

## ⚠️ Advertencias Importantes

### Esto es IRREVERSIBLE:
- No hay papelera de reciclaje
- No hay forma de recuperar los datos
- Todos los gastos asociados se eliminan (CASCADE)
- El usuario no puede recuperar su cuenta

### Datos que se eliminan:
```
Usuario (auth.users)
    ├── Todos sus gastos (expenses)
    ├── Su perfil (profiles)
    ├── Su nombre completo
    └── Su foto de perfil
```

## 🔄 Alternativa: Si cometes un error

Si eliminas un usuario por accidente:
1. **No hay forma de recuperarlo desde Supabase**
2. **Opción**: El usuario puede registrarse de nuevo con el mismo email

## 📊 Ver información ANTES de eliminar

Si quieres ver cuántos gastos tiene un usuario antes de eliminarlo:

### Opción 1: SQL Editor
```sql
SELECT 
  p.full_name,
  p.email,
  COUNT(e.id) as total_gastos,
  COALESCE(SUM(e.amount), 0) as total_gastado
FROM profiles p
LEFT JOIN expenses e ON p.id = e.user_id
WHERE p.email = 'usuario@example.com'
GROUP BY p.id, p.full_name, p.email;
```

### Opción 2: Directamente en el Dashboard
1. Ve a `SQL Editor`
2. Ejecuta la query anterior con el email del usuario
3. Verás cuántos gastos tiene antes de eliminarlo

## ✅ Checklist antes de eliminar

- [ ] ¿Es el usuario correcto? (Verifica email)
- [ ] ¿Quieres eliminar TODOS sus gastos?
- [ ] ¿Has hecho backup de los datos importantes?
- [ ] ¿Estás seguro? (Es irreversible)

## 🎯 Resumen de lo que sucede cuando eliminas:

| Acción | Efecto |
|--------|--------|
| Eliminas usuario en Auth | ✓ Usuario se borra de `auth.users` |
| ON DELETE CASCADE | ✓ Gastos se borran automáticamente |
| ON DELETE CASCADE | ✓ Perfil se borra automáticamente |
| - | ✓ Foto desaparece |
| - | ✓ Nombre del usuario desaparece |
| - | ✓ Email se libera (puede registrarse de nuevo) |

## 💾 Para una limpieza más controlada desde SQL

Si prefieres tener más control, ve a `SQL Editor` y usa:

### Ver usuarios:
```sql
SELECT id, email, created_at FROM auth.users;
```

### Eliminar un usuario específico (necesitas el ID):
```sql
DELETE FROM expenses WHERE user_id = 'id-uuid-aqui';
DELETE FROM profiles WHERE id = 'id-uuid-aqui';
```

### Ver gastos antes de eliminar:
```sql
SELECT * FROM expenses WHERE user_id = 'id-uuid-aqui';
```

---

**Nota**: El método más seguro es usar el Dashboard de Supabase (como en tu screenshot) porque:
- Es visual y confirmas quién eliminas
- Supabase maneja automáticamente las cascadas
- Es más difícil cometer errores
