# Informe de ventas por categoría — Etapa 4

## 1. Objetivo

El informe de ventas por categoría permite analizar el desempeño comercial de los productos agrupándolos según su clasificación. Para un período determinado, calcula cuántas unidades se vendieron y qué importe representan.

Esta información puede utilizarse para reconocer las categorías con mayor movimiento y apoyar decisiones relacionadas con compras, reposición de inventario y estrategia comercial.

## 2. Datos del informe

| Columna | Descripción |
|---|---|
| `id_categoria` | Identificador de la categoría. |
| `categoria` | Nombre de la categoría del producto. |
| `unidades_vendidas` | Suma de las cantidades registradas en los detalles de venta. |
| `monto_total_ventas` | Suma de cantidad por precio unitario para los productos de esa categoría. |

## 3. Funcionamiento

La consulta relaciona las siguientes tablas:

1. `CATEGORIA` con `PRODUCTO`, para conocer la categoría de cada artículo.
2. `PRODUCTO` con `DETALLE_VENTA`, para recuperar las unidades y los precios vendidos.
3. `DETALLE_VENTA` con `VENTA`, para limitar los resultados al período solicitado.

El rango temporal se establece mediante una condición sobre `VENTA.fecha`:

```sql
WHERE v.fecha >= '2026-01-01T00:00:00'
  AND v.fecha <= '2026-12-31T23:59:59'
```

Los resultados se agrupan por identificador y nombre de categoría:

```sql
GROUP BY cat.id_categoria, cat.nombre
```

Se calculan dos agregaciones:

```sql
SUM(dv.cantidad) AS unidades_vendidas
```

```sql
SUM(dv.cantidad * dv.precio_unitario) AS monto_total_ventas
```

Finalmente, se ordenan las categorías por el importe generado, de mayor a menor:

```sql
ORDER BY monto_total_ventas DESC;
```

## 4. Conceptos de bases de datos aplicados

- **JOIN:** integra información distribuida en distintas tablas relacionadas.
- **WHERE:** filtra las ventas que pertenecen al período seleccionado.
- **GROUP BY:** reúne los registros que comparten una misma categoría.
- **SUM():** calcula los totales de unidades e importes.
- **Alias (`AS`):** asigna nombres descriptivos a las columnas del resultado.
- **ORDER BY DESC:** permite priorizar las categorías con mayor importe.

## 5. Interpretación del resultado

Cada fila representa una categoría que tiene productos asociados a detalles de venta dentro del período consultado. `unidades_vendidas` expresa el volumen de artículos comercializados, mientras que `monto_total_ventas` representa la suma de los subtotales de esos artículos.

El importe se calcula a partir de los precios unitarios históricos guardados en `DETALLE_VENTA`, no del precio actual de `PRODUCTO`. Esto es importante porque el precio de catálogo puede cambiar después de concretarse una operación.

## 6. Consideraciones y posibles adaptaciones

El script utiliza el año 2026 como rango fijo de ejemplo. Para analizar otro período se deben modificar las fechas del `WHERE`. En una versión más flexible, esas fechas podrían recibirse como parámetros de un procedimiento almacenado.

El uso de `INNER JOIN` hace que no aparezcan categorías sin ventas en el período. Además, el importe calculado corresponde a la suma de los detalles y no necesariamente al campo `VENTA.total` cuando se aplican descuentos u otros ajustes a nivel de venta.

## 7. Archivo SQL relacionado

La consulta se encuentra en la sección **Reporte** de `sql/ETAPA4PRUEBA.SQL`.
