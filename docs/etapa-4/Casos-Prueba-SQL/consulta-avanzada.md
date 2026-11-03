# Consulta avanzada de negocio — Etapa 4

## 1. Objetivo

La consulta avanzada de negocio busca identificar clientes cuyo gasto acumulado supera el promedio general de los importes de venta registrados. Su propósito es obtener un indicador sencillo del comportamiento de compra y reconocer clientes con un volumen de consumo elevado respecto de ese promedio.

La consulta se basa en las tablas `CLIENTE` y `VENTA` y utiliza agrupaciones, funciones de agregación y una subconsulta.

## 2. Información obtenida

El resultado presenta:

| Columna | Descripción |
|---|---|
| `id_cliente` | Identificador del cliente. |
| `cliente` | Nombre y apellido. |
| `cantidad_compras` | Cantidad de ventas registradas para el cliente. |
| `total_gastado` | Suma de los importes de sus ventas. |

Los resultados se ordenan por `total_gastado` de mayor a menor, de modo que los clientes con mayor gasto aparecen primero.

## 3. Funcionamiento

Primero, `CLIENTE` se relaciona con `VENTA` mediante `INNER JOIN`:

```sql
INNER JOIN VENTA v ON c.id_cliente = v.id_cliente
```

Luego se agrupan las ventas por cliente:

```sql
GROUP BY c.id_cliente, c.nombre, c.apellido
```

Para cada grupo se calculan la cantidad de operaciones y el gasto acumulado:

```sql
COUNT(v.id_venta) AS cantidad_compras,
SUM(v.total) AS total_gastado
```

La condición `HAVING` compara el gasto acumulado de cada cliente con el promedio general de los importes individuales de la tabla `VENTA`:

```sql
HAVING SUM(v.total) > (
    SELECT AVG(total)
    FROM VENTA
)
```

La subconsulta obtiene un único valor: el promedio de `VENTA.total`. La consulta externa conserva solamente los clientes cuyo gasto total supera ese valor.

## 4. Conceptos de bases de datos aplicados

- **Subconsulta:** consulta anidada que proporciona un valor utilizado por la consulta principal.
- **AVG():** calcula el promedio de los importes de venta.
- **SUM():** calcula el gasto acumulado de cada cliente.
- **COUNT():** cuenta las ventas de cada cliente.
- **GROUP BY:** agrupa las operaciones para obtener resultados por cliente.
- **HAVING:** filtra grupos luego de aplicar las funciones de agregación.
- **INNER JOIN:** relaciona los clientes con sus ventas.
- **ORDER BY DESC:** ordena los resultados desde el mayor gasto hacia el menor.

## 5. Diferencia entre WHERE y HAVING

`WHERE` filtra filas individuales antes de que se realice la agrupación. En cambio, `HAVING` filtra los grupos resultantes y permite utilizar condiciones basadas en agregaciones como `SUM()`, `COUNT()` o `AVG()`.

En esta consulta se necesita `HAVING` porque la condición no evalúa una venta aislada, sino la suma de todas las ventas de cada cliente.

## 6. Interpretación y alcance

Es importante interpretar correctamente el criterio utilizado: se compara el **gasto acumulado de cada cliente** contra el **promedio de los importes de cada venta individual**.

Por lo tanto, el resultado identifica clientes cuyo gasto total supera el valor promedio de una venta, no necesariamente clientes cuyo gasto promedio por compra sea superior al promedio general. La denominación de cliente VIP funciona aquí como un criterio analítico de ejemplo y no como una categoría permanente almacenada en la base.

Si la tabla `VENTA` no contiene registros, el promedio no podrá calcularse como un valor numérico y la consulta no devolverá clientes.

## 7. Posible ampliación

El criterio puede adaptarse según las necesidades del comercio. Por ejemplo, se podría comparar el promedio de gasto por cliente con el promedio general por cliente, limitar el análisis a un período determinado o establecer un monto mínimo de compras para definir una categoría VIP.

## 8. Archivo SQL relacionado

La consulta se encuentra en la sección **Consulta de Negocio** de `sql/ETAPA4PRUEBA.SQL`. Una versión de la consulta también aparece al comienzo de `docs/etapa-4/Casos-Prueba-SQL/Casos_de_Pruebas_EtapaIV_.sql`.
