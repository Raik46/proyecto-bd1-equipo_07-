/*
  TechGamer - SQL + casos de uso

  Requiere ejecutar previamente DDL_techgamer.sql y DML_techgamer.sql.
*/

USE techgamer;
GO

/* CASO DE USO 1
   Objetivo: detectar productos que necesitan reposición.
   Criterio: mostrar productos con menos de 10 unidades en stock.
*/
SELECT
    P.id_producto,
    P.nombre AS producto,
    P.stock,
    P.precio
FROM PRODUCTO AS P
WHERE P.stock < 10
ORDER BY P.stock ASC, P.nombre;
GO

/* CASO DE USO 2
   Objetivo: consultar las ventas con los datos de quienes participaron.
   Devuelve fecha, cliente, empleado, forma de pago e importe.
*/
SELECT
    V.id_venta,
    V.fecha,
    CONCAT(C.nombre, ' ', C.apellido) AS cliente,
    CONCAT(E.nombre, ' ', E.apellido) AS empleado,
    FP.descripcion AS forma_pago,
    V.total
FROM VENTA AS V
INNER JOIN CLIENTE AS C
    ON V.id_cliente = C.id_cliente
INNER JOIN EMPLEADO AS E
    ON V.id_empleado = E.id_empleado
INNER JOIN FORMA_PAGO AS FP
    ON V.id_forma_pago = FP.id_forma_pago
ORDER BY V.fecha DESC;
GO

/* CASO DE USO 3
   Objetivo: conocer cuánto se vendió y cuántas ventas se registraron.
   Se usa LEFT JOIN para incluir también clientes sin ventas.
*/
SELECT
    C.id_cliente,
    CONCAT(C.nombre, ' ', C.apellido) AS cliente,
    COUNT(V.id_venta) AS cantidad_ventas,
    COALESCE(SUM(V.total), 0) AS total_comprado
FROM CLIENTE AS C
LEFT JOIN VENTA AS V
    ON V.id_cliente = C.id_cliente
GROUP BY C.id_cliente, C.nombre, C.apellido
ORDER BY total_comprado DESC, cliente;
GO
