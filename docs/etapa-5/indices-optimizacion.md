# Índices y optimización

Base de datos: `techgamer` (SQL Server). Scripts: `EtapaV_Indices.sql` (creación), `EtapaV_Demo_Indices.sql` y `EtapaV_Demo_Optimizacion_Indices.sql` (pruebas).

## Índices que ya existían

SQL Server crea solos:

- Un índice agrupado (clustered) por cada `PRIMARY KEY`.
- Un índice no agrupado por cada `UNIQUE` (`dni`, `legajo`, `cuil`, nombre de categoría, descripción de forma de pago y `(id_venta, id_producto)` en el detalle).

No crea índices sobre las claves foráneas, por eso se agregaron los de abajo.

## Índices creados

| Tabla | Índice | Columnas | Para qué |
|---|---|---|---|
| `VENTA` | `IX_VENTA_id_cliente` | `id_cliente` (incluye `total`, `fecha`) | Total por cliente, lo usa la función de descuento |
| `VENTA` | `IX_VENTA_fecha` | `fecha` (incluye `total`, `id_cliente`, `id_empleado`) | Reportes por rango de fechas |
| `VENTA` | `IX_VENTA_id_empleado` | `id_empleado` | Ventas por empleado |
| `DETALLE_VENTA` | `IX_DETALLE_id_producto` | `id_producto` (incluye `cantidad`, `precio_unitario`) | Ventas por producto |
| `PRODUCTO` | `IX_PRODUCTO_id_categoria` | `id_categoria` (incluye `nombre`, `precio`, `stock`) | Listado por categoría |
| `PRODUCTO` | `IX_PRODUCTO_id_proveedor` | `id_proveedor` | Productos por proveedor |
| `PRODUCTO` | `IX_PRODUCTO_nombre` | `nombre` | Búsqueda por nombre |
| `CLIENTE` | `IX_CLIENTE_apellido_nombre` | `(apellido, nombre)` | Búsqueda por apellido y nombre |
| `AUDITORIA` | `IX_AUDITORIA_tabla_registro` | `(tabla, id_registro)` | Historial de un registro |
| `AUDITORIA` | `IX_AUDITORIA_fecha` | `fecha` | Consultas por fecha |

### Índice filtrado

`IX_PRODUCTO_stock_bajo` indexa `stock` solo para los productos con `stock <= 10`. Es mucho más chico que un índice completo y alcanza para el listado de productos a reponer.

### Por qué INCLUDE

Con `INCLUDE` las columnas extra quedan guardadas en el índice, entonces la consulta se resuelve sin volver a la tabla (índice cubridor). Por eso en `IX_VENTA_id_cliente` se incluye `total`.

## Demostración de optimización

Con 10 filas por tabla el motor siempre recorre todo y no se nota la mejora. Por eso se creó la tabla `VENTA_PRUEBA` con 500.000 filas, se midió la misma consulta antes y después de crear el índice, y la tabla se borra al final.

La métrica es **lecturas lógicas** (páginas leídas), que se ve en la pestaña Mensajes con `SET STATISTICS IO ON`. Menos lecturas es mejor. Antes de cada medición se limpia la caché con `DBCC DROPCLEANBUFFERS` y `DBCC FREEPROCCACHE` (solo en entornos de prueba).

| Prueba | Sin índice | Con índice |
|---|---|---|
| A. Total de un cliente | Clustered Index Scan, recorre toda la tabla | Index Seek, solo las filas del cliente |
| B. Ventas de los últimos 2 días | Clustered Index Scan | Index Seek sobre `fecha` |
| C. Igual que B pero pidiendo `id_forma_pago`, que el índice no incluye | — | Seek + Key Lookup por cada fila, más lecturas |

La prueba C muestra que un índice que no cubre la consulta ayuda menos, y que conviene incluir las columnas que se piden seguido.

<!-- completar acá con los números reales de lecturas lógicas y tiempos que salgan al ejecutar -->

## Mantenimiento

Con el uso los índices se fragmentan. Se revisa con `sys.dm_db_index_physical_stats` y se aplica la regla habitual:

- Entre 5% y 30% de fragmentación: `ALTER INDEX ... REORGANIZE`.
- Más de 30%: `ALTER INDEX ... REBUILD`.

## Contra de tener muchos índices

Cada índice ocupa espacio y hace más lentos los `INSERT`, `UPDATE` y `DELETE`, porque hay que mantenerlo actualizado. Por eso solo se crearon los que responden a consultas reales del sistema.
