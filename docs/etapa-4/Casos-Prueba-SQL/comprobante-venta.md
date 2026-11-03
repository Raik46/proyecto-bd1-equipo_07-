# Comprobante de venta — Etapa 4

## 1. Objetivo

La consulta de comprobante de venta tiene como finalidad reunir en un único resultado la información de la cabecera de una operación comercial y los productos que forman parte de ella.

Este reporte permite visualizar qué se vendió, en qué cantidad, a qué precio y cuál es el subtotal correspondiente a cada renglón. También muestra un importe acumulado a medida que se recorren los detalles de la venta.

## 2. Información presentada

El resultado contiene las siguientes columnas:

| Columna | Descripción |
|---|---|
| `numero_venta` | Identificador de la venta. |
| `fecha_venta` | Fecha y hora en que se registró la operación. |
| `cliente` | Nombre y apellido del cliente. |
| `empleado` | Nombre y apellido del empleado que registró la venta. |
| `producto` | Nombre del producto vendido. |
| `cantidad` | Unidades incluidas en el renglón. |
| `precio_unitario` | Precio por unidad registrado en el detalle. |
| `subtotal_renglon` | Resultado de multiplicar cantidad por precio unitario. |
| `total_acumulado` | Suma progresiva de los subtotales dentro de la venta. |

## 3. Funcionamiento de la consulta

La consulta relaciona cinco tablas mediante `INNER JOIN`:

- `VENTA` aporta la identificación y fecha de la operación.
- `CLIENTE` permite mostrar quién realizó la compra.
- `EMPLEADO` identifica quién registró la venta.
- `DETALLE_VENTA` contiene las cantidades y los precios unitarios históricos.
- `PRODUCTO` aporta la descripción de cada artículo.

El subtotal de cada renglón se calcula con la expresión:

```sql
dv.cantidad * dv.precio_unitario
```

Para obtener el importe acumulado se utiliza la función de ventana `SUM() OVER`, particionada por el identificador de venta y ordenada por el identificador del detalle:

```sql
SUM(dv.cantidad * dv.precio_unitario) OVER (
    PARTITION BY v.id_venta
    ORDER BY dv.id_detalle
)
```

`PARTITION BY` reinicia la acumulación para cada venta, mientras que `ORDER BY` establece el orden en que se suman los renglones.

La consulta de demostración limita el resultado a la venta cuyo identificador es `1`:

```sql
WHERE v.id_venta = 1;
```

Para consultar otra operación se puede reemplazar ese valor por el identificador correspondiente.

## 4. Conceptos de bases de datos aplicados

- **INNER JOIN:** combina registros relacionados y evita mostrar filas sin correspondencia en las tablas vinculadas.
- **Claves primarias y foráneas:** permiten relacionar la cabecera de venta con el cliente, el empleado y sus detalles.
- **Expresiones calculadas:** permiten obtener subtotales sin almacenarlos como columnas adicionales.
- **Funciones de ventana:** realizan cálculos sobre un conjunto de filas relacionadas sin agruparlas en una sola fila.
- **PARTITION BY:** define el grupo dentro del cual se calcula el acumulado.
- **ORDER BY:** determina la secuencia de cálculo y presentación.

## 5. Consideraciones

El importe acumulado es una suma progresiva de los subtotales de los detalles; no es una columna almacenada ni equivale necesariamente al campo `VENTA.total` si existen descuentos u otros ajustes.

La consulta actual muestra el detalle y el acumulado, pero no incluye la forma de pago ni presenta explícitamente el total final almacenado en `VENTA.total`. Tampoco aplica formato monetario: los valores se devuelven como datos numéricos para que puedan procesarse o presentarse desde otra capa.

## 6. Archivo SQL relacionado

La consulta se encuentra en la sección **Comprobante** de `sql/ETAPA4PRUEBA.SQL`.
