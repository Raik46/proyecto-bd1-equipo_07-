# Casos de uso — Etapa 4

## 1. Objetivo

Esta etapa presenta consultas SQL orientadas a resolver necesidades concretas de gestión de la tienda **TechGamer**. A partir de las tablas creadas en las etapas anteriores, se obtiene información útil para analizar las ventas, controlar el inventario y conocer el comportamiento de los clientes.

Las consultas se ejecutan sobre la base de datos `techgamer`, implementada en Microsoft SQL Server.

## 2. Actores y necesidades

Los principales usuarios que pueden beneficiarse de estas consultas son:

- **Vendedor:** necesita consultar información de las operaciones y verificar los productos involucrados en una venta.
- **Encargado o gerente:** necesita analizar las ventas, los medios de pago y el desempeño comercial.
- **Responsable de inventario:** necesita identificar productos con pocas unidades o que todavía no registran ventas.
- **Administración:** necesita identificar clientes con mayor volumen de compras.

## 3. Casos de uso implementados

### Caso 1 — Consultar el comprobante de una venta

Permite recuperar los datos principales de una venta y el detalle de los productos adquiridos. Se muestran el número y la fecha de la venta, el cliente, el empleado, el producto, la cantidad, el precio unitario y el subtotal por renglón.

Además, se calcula un total acumulado mediante una función de ventana. La consulta de demostración filtra la venta con identificador `1`.

**Tablas involucradas:** `VENTA`, `CLIENTE`, `EMPLEADO`, `DETALLE_VENTA` y `PRODUCTO`.

### Caso 2 — Obtener un informe de ventas por categoría

Permite analizar las unidades vendidas y el importe generado por cada categoría dentro de un período determinado. Los resultados se agrupan por categoría y se ordenan desde el mayor importe de ventas hacia el menor.

**Tablas involucradas:** `CATEGORIA`, `PRODUCTO`, `DETALLE_VENTA` y `VENTA`.

### Caso 3 — Identificar clientes con mayor volumen de compras

Permite encontrar clientes cuyo gasto acumulado supera el promedio general de los importes registrados en la tabla `VENTA`. Para cada cliente se informa la cantidad de compras y el total gastado.

La comparación se realiza mediante una subconsulta dentro de `HAVING`.

**Tablas involucradas:** `CLIENTE` y `VENTA`.

### Caso 4 — Agrupar ventas por forma de pago

Muestra, para cada forma de pago que tenga operaciones asociadas, la cantidad de ventas y el monto total registrado. Los resultados se ordenan por importe vendido de mayor a menor.

**Tablas involucradas:** `FORMA_PAGO` y `VENTA`.

### Caso 5 — Detectar productos con stock bajo

Identifica productos cuyo stock es mayor que cero y menor que cinco unidades. Se muestra el nombre del producto, la cantidad disponible y su categoría. El orden prioriza los productos con menor existencia.

**Tablas involucradas:** `PRODUCTO` y `CATEGORIA`.

### Caso 6 — Encontrar productos que no registran ventas

Permite identificar productos que no aparecen en ningún detalle de venta. Se utiliza `LEFT JOIN` para conservar todos los productos y luego se filtran aquellos para los que no existe un detalle asociado.

**Tablas involucradas:** `PRODUCTO`, `CATEGORIA` y `DETALLE_VENTA`.

## 4. Importancia de los casos de uso

Estos escenarios muestran cómo una misma base de datos puede responder a necesidades diferentes según la información que se consulte y la forma en que se relacionen las tablas. Las consultas no se limitan a recuperar registros individuales: también permiten agrupar, resumir, comparar y detectar situaciones relevantes para la gestión del comercio.

## 5. Archivos SQL relacionados

- `sql/ETAPA4PRUEBA.SQL`: contiene la consulta del comprobante, el informe por categoría y la consulta de clientes con gasto superior al promedio.
- `docs/etapa-4/Casos-Prueba-SQL/Casos_de_Pruebas_EtapaIV_.sql`: contiene consultas adicionales para ventas por forma de pago, productos con stock bajo y productos sin ventas, además de pruebas controladas.
