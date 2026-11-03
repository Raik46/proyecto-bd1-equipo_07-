# Triggers y auditoría

Base de datos: `techgamer` (SQL Server).

## Qué se hizo

Se usa una tabla `AUDITORIA` que guarda un registro cada vez que se modifica una tabla del sistema. Los triggers se encargan de cargarla automáticamente, sin que el usuario ni el procedimiento tengan que acordarse de hacerlo.

## Tabla AUDITORIA

| Columna | Qué guarda |
|---|---|
| `id_auditoria` | Identificador del registro de auditoría |
| `tabla` | Tabla que se modificó |
| `operacion` | Tipo de operación (INSERT, UPDATE o DELETE) |
| `id_registro` | Id de la fila afectada |
| `usuario` | Usuario que hizo el cambio |
| `fecha` | Cuándo se hizo |

## Triggers

<!-- completar con el nombre real de cada trigger y la tabla donde está -->

| Trigger | Tabla | Se dispara con |
|---|---|---|
| | | |

## Cómo se comprobó

En la demo de seguridad, el vendedor registra una venta usando `sp_RegistrarVentaCompleta`. Después el auditor consulta la tabla:

```sql
SELECT TOP 5 id_auditoria, tabla, operacion, id_registro, usuario, fecha
FROM dbo.AUDITORIA
ORDER BY id_auditoria DESC;
```

Ahí aparece la venta recién hecha, con el usuario que la ejecutó. Eso confirma que el trigger funciona aunque el cambio venga desde un procedimiento.

## Protección de la auditoría

La auditoría no sirve si se puede borrar, así que se limitaron los permisos (más detalle en `seguridad.md`):

- El **auditor** puede leerla pero no modificarla.
- El **gerente** puede leerla pero tiene `DENY` de insert, update y delete.
- El **vendedor** no puede ni leerla.

## Índices

Para que las consultas sobre la auditoría sean rápidas se agregaron dos índices:

- `IX_AUDITORIA_tabla_registro` sobre `(tabla, id_registro)`: sirve para ver el historial de un registro puntual.
- `IX_AUDITORIA_fecha` sobre `fecha`: sirve para consultas por período.
