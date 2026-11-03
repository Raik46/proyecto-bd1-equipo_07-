# Seguridad

Base de datos: `techgamer` (SQL Server). Scripts: `EtapaV_Seguridad.sql` (configuración) y `EtapaV_Seguridad_Demo.sql` (pruebas).

## Qué se hizo

Se separó el acceso en tres perfiles con permisos distintos, y se enmascararon los datos personales de los clientes.

## Logins, usuarios y roles

| Login | Usuario en la base | Rol |
|---|---|---|
| `login_vendedor` | `usr_vendedor` | `rol_vendedor` |
| `login_gerente` | `usr_gerente` | `rol_gerente` |
| `login_auditor` | `usr_auditor` | `rol_auditor` |

El login permite entrar al servidor, el usuario existe dentro de la base y el rol agrupa los permisos. Las contraseñas del script son de ejemplo y se tienen que cambiar si se usa en un entorno real.

## Permisos por rol

**Vendedor**
- Puede leer `PRODUCTO`, `CATEGORIA`, `CLIENTE` y `FORMA_PAGO`.
- Puede ejecutar `sp_RegistrarVentaCompleta` y `fn_CalcularDescuentoCliente`.
- No puede insertar, modificar ni borrar en `VENTA`, `DETALLE_VENTA` ni `PRODUCTO`.
- No puede leer `AUDITORIA` ni `EMPLEADO`.

**Gerente**
- Lee todas las tablas (`db_datareader`).
- Puede ejecutar el procedimiento y la función.
- Tiene `UNMASK`, o sea que ve los datos de clientes completos.
- No puede modificar la auditoría.

**Auditor**
- Solo puede leer `AUDITORIA`.
- No puede leer `CLIENTE`.
- No puede modificar la auditoría.

## Por qué el vendedor puede vender sin tener permiso de escritura

Tiene `DENY` de insert sobre `VENTA`, pero igual puede registrar ventas con el procedimiento. Esto funciona porque el procedimiento y las tablas tienen el mismo dueño, entonces SQL Server no vuelve a revisar los permisos de las tablas dentro del procedimiento (encadenamiento de propiedad). Así el vendedor solo puede vender por el camino que respeta las validaciones.

## Enmascaramiento de datos (Dynamic Data Masking)

Se aplicó sobre `CLIENTE`:

| Columna | Función | Ejemplo de lo que ve el vendedor |
|---|---|---|
| `dni` | `partial(0, "XXXX", 4)` | `XXXX3456` |
| `email` | `email()` | `jXXX@XXXX.com` |
| `telefono` | `partial(0, "XXX-XXX-", 4)` | `XXX-XXX-1001` |

Quien tiene `UNMASK` (el gerente) ve los valores reales. Los datos no se modifican en la tabla, solo cambia lo que devuelve la consulta.

## Pruebas realizadas

| Prueba | Resultado esperado |
|---|---|
| Vendedor lee clientes | Datos enmascarados |
| Gerente lee clientes | Datos completos |
| Vendedor hace `UPDATE` de un precio | Bloqueado |
| Vendedor inserta una venta directo | Bloqueado |
| Vendedor vende con el procedimiento | Permitido |
| Vendedor lee la auditoría | Bloqueado |
| Auditor lee la auditoría | Permitido, aparece la venta anterior |
| Auditor lee clientes | Bloqueado |
| Gerente borra la auditoría | Bloqueado |

La demo usa `EXECUTE AS USER` para correr cada consulta como ese usuario y `REVERT` para volver al original. Al final hay una consulta a `sys.database_permissions` que lista los permisos de cada rol.
