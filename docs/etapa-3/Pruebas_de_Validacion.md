# Pruebas de validacion

Para comprobar que la base de datos funciona correctamente se hicieron distintas pruebas usando los datos de prueba cargados, la idea es revisar que los datos se hayan guardado bien y que las relaciones entre las tablas funcionen como se esperaba,

## 1, comprobar que los datos se cargaron

Primero se puede revisar cuantos registros tiene cada tabla,

```sql
SELECT 'CATEGORIA' AS tabla, COUNT(*) AS cantidad FROM CATEGORIA
UNION ALL
SELECT 'PROVEEDOR', COUNT(*) FROM PROVEEDOR
UNION ALL
SELECT 'PRODUCTO', COUNT(*) FROM PRODUCTO
UNION ALL
SELECT 'CLIENTE', COUNT(*) FROM CLIENTE
UNION ALL
SELECT 'EMPLEADO', COUNT(*) FROM EMPLEADO
UNION ALL
SELECT 'FORMA_PAGO', COUNT(*) FROM FORMA_PAGO
UNION ALL
SELECT 'VENTA', COUNT(*) FROM VENTA
UNION ALL
SELECT 'DETALLE_VENTA', COUNT(*) FROM DETALLE_VENTA;
```

### Resultado esperado

| Tabla | Cantidad |
|---|---:|
| CATEGORIA | 10 |
| PROVEEDOR | 10 |
| PRODUCTO | 10 |
| CLIENTE | 10 |
| EMPLEADO | 8 |
| FORMA_PAGO | 8 |
| VENTA | 10 |
| DETALLE_VENTA | 16 |

Si aparecen esas cantidades significa que los datos de prueba se cargaron correctamente,

## 2, comprobar productos, categorias y proveedores

Se revisa que cada producto este relacionado con una categoria y un proveedor,

```sql
SELECT
    p.id_producto,
    p.nombre AS producto,
    c.nombre AS categoria,
    pr.razon_social AS proveedor
FROM PRODUCTO p
INNER JOIN CATEGORIA c
    ON p.id_categoria = c.id_categoria
INNER JOIN PROVEEDOR pr
    ON p.id_proveedor = pr.id_proveedor
ORDER BY p.id_producto;
```

### Resultado esperado

Deben aparecer los 10 productos, mostrando la categoria y el proveedor que corresponde a cada uno,

## 3, comprobar las ventas

Se revisa que cada venta tenga un cliente, un empleado y una forma de pago asociados,

```sql
SELECT
    v.id_venta,
    v.fecha,
    c.nombre + ' ' + c.apellido AS cliente,
    e.nombre + ' ' + e.apellido AS empleado,
    fp.descripcion AS forma_pago,
    v.total
FROM VENTA v
INNER JOIN CLIENTE c
    ON v.id_cliente = c.id_cliente
INNER JOIN EMPLEADO e
    ON v.id_empleado = e.id_empleado
INNER JOIN FORMA_PAGO fp
    ON v.id_forma_pago = fp.id_forma_pago
ORDER BY v.id_venta;
```

### Resultado esperado

Deben aparecer las 10 ventas con los datos correspondientes de cada cliente, empleado y forma de pago,

## 4, comprobar los detalles de las ventas

Se revisa que cada detalle este relacionado con una venta y con un producto,

```sql
SELECT
    dv.id_detalle,
    dv.id_venta,
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario
FROM DETALLE_VENTA dv
INNER JOIN PRODUCTO p
    ON dv.id_producto = p.id_producto
ORDER BY dv.id_venta, dv.id_detalle;
```

### Resultado esperado

Deben aparecer los 16 detalles que fueron cargados en los datos de prueba,

## 5, comprobar los totales de las ventas

Se puede comprobar que el total guardado en cada venta coincida con la suma de sus productos,

```sql
SELECT
    v.id_venta,
    v.total AS total_venta,
    SUM(dv.cantidad * dv.precio_unitario) AS total_calculado,
    v.total - SUM(dv.cantidad * dv.precio_unitario) AS diferencia
FROM VENTA v
INNER JOIN DETALLE_VENTA dv
    ON v.id_venta = dv.id_venta
GROUP BY v.id_venta, v.total
ORDER BY v.id_venta;
```

### Resultado esperado

La diferencia deberia ser `0` en todas las ventas,

Los totales esperados son,

| Venta | Total |
|---|---:|
| 1 | 73000,00 |
| 2 | 104000,00 |
| 3 | 210000,00 |
| 4 | 266000,00 |
| 5 | 620000,00 |
| 6 | 183000,00 |
| 7 | 260000,00 |
| 8 | 129000,00 |
| 9 | 133000,00 |
| 10 | 142000,00 |

## 6, comprobar el stock

Se revisa que los productos tengan el stock cargado y que no haya valores negativos,

```sql
SELECT
    id_producto,
    nombre,
    stock
FROM PRODUCTO
ORDER BY id_producto;
```

### Resultado esperado

Todos los productos deben tener un stock mayor o igual a `0`,

## 7, comprobar clientes y ventas

Se revisa cuantos ventas tiene asociada cada cliente,

```sql
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    COUNT(v.id_venta) AS cantidad_ventas
FROM CLIENTE c
LEFT JOIN VENTA v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY c.id_cliente;
```

### Resultado esperado

Deben aparecer los 10 clientes, mostrando la cantidad de ventas que tiene cada uno,

## 8, comprobar empleados y ventas

Se hace algo parecido con los empleados, para comprobar cuales registraron ventas,

```sql
SELECT
    e.id_empleado,
    e.nombre,
    e.apellido,
    COUNT(v.id_venta) AS cantidad_ventas
FROM EMPLEADO e
LEFT JOIN VENTA v
    ON e.id_empleado = v.id_empleado
GROUP BY e.id_empleado, e.nombre, e.apellido
ORDER BY e.id_empleado;
```

### Resultado esperado

Deben aparecer los 8 empleados, indicando cuantas ventas tiene registrada cada uno,

## 9, comprobar que no haya datos repetidos

Como algunas columnas tienen que ser unicas, se revisa que no existan valores repetidos,

```sql
SELECT nombre, COUNT(*) AS cantidad
FROM CATEGORIA
GROUP BY nombre
HAVING COUNT(*) > 1;

SELECT cuil, COUNT(*) AS cantidad
FROM PROVEEDOR
GROUP BY cuil
HAVING COUNT(*) > 1;

SELECT dni, COUNT(*) AS cantidad
FROM CLIENTE
GROUP BY dni
HAVING COUNT(*) > 1;

SELECT legajo, COUNT(*) AS cantidad
FROM EMPLEADO
GROUP BY legajo
HAVING COUNT(*) > 1;

SELECT descripcion, COUNT(*) AS cantidad
FROM FORMA_PAGO
GROUP BY descripcion
HAVING COUNT(*) > 1;
```

### Resultado esperado

Las consultas no deberian devolver ningun registro, porque esos valores no pueden repetirse,

## 10, comprobar que un producto no se repita dentro de una venta

Se revisa la combinacion entre venta y producto, ya que el mismo producto no deberia aparecer dos veces dentro de una misma venta,

```sql
SELECT
    id_venta,
    id_producto,
    COUNT(*) AS cantidad
FROM DETALLE_VENTA
GROUP BY id_venta, id_producto
HAVING COUNT(*) > 1;
```

### Resultado esperado

No deberia aparecer ningun registro,

## 11, probar una clave foranea

Se intenta agregar un detalle usando una venta que no existe,

```sql
INSERT INTO DETALLE_VENTA
    (cantidad, precio_unitario, id_venta, id_producto)
VALUES
    (1, 50000.00, 999, 1);
```

### Resultado esperado

La base de datos deberia rechazar la operacion, porque la venta `999` no existe,

## 12, probar un precio negativo

Se intenta agregar un producto con un precio menor que cero,

```sql
INSERT INTO PRODUCTO
    (nombre, precio, stock, id_categoria, id_proveedor)
VALUES
    ('Producto de prueba', -1000.00, 5, 1, 1);
```

### Resultado esperado

La operacion deberia ser rechazada porque el precio tiene que ser mayor que `0`,

## 13, probar un stock negativo

Se intenta agregar un producto con stock negativo,

```sql
INSERT INTO PRODUCTO
    (nombre, precio, stock, id_categoria, id_proveedor)
VALUES
    ('Producto de prueba', 1000.00, -5, 1, 1);
```

### Resultado esperado

La operacion deberia ser rechazada porque el stock no puede ser menor que `0`,

## 14, probar una cantidad invalida

Se intenta agregar un detalle con cantidad igual a cero,

```sql
INSERT INTO DETALLE_VENTA
    (cantidad, precio_unitario, id_venta, id_producto)
VALUES
    (0, 45000.00, 1, 3);
```

### Resultado esperado

La operacion deberia ser rechazada porque la cantidad tiene que ser mayor que `0`,

## 15, probar un precio unitario invalido

Se intenta agregar un detalle con un precio unitario negativo,

```sql
INSERT INTO DETALLE_VENTA
    (cantidad, precio_unitario, id_venta, id_producto)
VALUES
    (1, -45000.00, 1, 3);
```

### Resultado esperado

La operacion deberia ser rechazada porque el precio unitario tiene que ser mayor que `0`,

## 16, probar un total negativo

Se intenta crear una venta con un total negativo,

```sql
INSERT INTO VENTA
    (fecha, total, id_cliente, id_empleado, id_forma_pago)
VALUES
    ('2026-09-30T10:00:00', -5000.00, 1, 1, 1);
```

### Resultado esperado

La operacion deberia ser rechazada porque el total no puede ser menor que `0`,

## 17, probar un DNI incorrecto

Se intenta agregar un cliente con un DNI que no tiene el formato esperado,

```sql
INSERT INTO CLIENTE
    (nombre, apellido, dni, email, telefono)
VALUES
    ('Prueba', 'DNI', '1234', 'prueba@mail.com', '3790000000');
```

### Resultado esperado

La operacion deberia ser rechazada porque el DNI tiene que cumplir con el formato definido,

## 18, probar un CUIL incorrecto

Se intenta agregar un proveedor con un CUIL que no tiene el formato esperado,

```sql
INSERT INTO PROVEEDOR
    (cuil, razon_social, telefono, email)
VALUES
    ('123456789', 'Proveedor de prueba', '3790000000', 'prueba@mail.com');
```

### Resultado esperado

La operacion deberia ser rechazada porque el CUIL tiene que cumplir con el formato definido,

## Conclusion

Con estas pruebas se puede comprobar que los datos se cargaron correctamente y que las relaciones entre las tablas funcionan como se esperaba,

Tambien se comprueba que la base de datos no permita ingresar datos incorrectos, como precios negativos, stock negativo, cantidades invalidas o referencias a registros que no existen,
