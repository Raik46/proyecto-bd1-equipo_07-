/*
  TechGamer - SQL + casos de uso
  Etapa IV: Consultas y casos de uso

  Requiere ejecutar previamente DDL_techgamer.sql y DML_techgamer.sql.
*/

USE techgamer;
GO

/* CASO DE USO 1
   Objetivo: conocer las unidades vendidas y el monto total
   por cada categoría de producto durante el año 2026.
   Se utilizan SUM y GROUP BY para calcular los totales.
*/
SELECT
    C.id_categoria,
    C.nombre AS categoria,
    SUM(DV.cantidad) AS unidades_vendidas,
    SUM(DV.cantidad * DV.precio_unitario) AS monto_total_ventas
FROM CATEGORIA AS C
INNER JOIN PRODUCTO AS P
    ON C.id_categoria = P.id_categoria
INNER JOIN DETALLE_VENTA AS DV
    ON P.id_producto = DV.id_producto
INNER JOIN VENTA AS V
    ON DV.id_venta = V.id_venta
WHERE V.fecha >= '2026-01-01'
  AND V.fecha < '2027-01-01'
GROUP BY C.id_categoria, C.nombre
ORDER BY monto_total_ventas DESC;
GO


/* CASO DE USO 2
   Objetivo: consultar las ventas por categoría durante el
   primer semestre de 2026.
   Se utiliza un rango de fechas para excluir las ventas
   realizadas fuera del período seleccionado.
*/
SELECT
    C.id_categoria,
    C.nombre AS categoria,
    SUM(DV.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT V.id_venta) AS cantidad_ventas,
    SUM(DV.cantidad * DV.precio_unitario) AS monto_total_ventas
FROM CATEGORIA AS C
INNER JOIN PRODUCTO AS P
    ON C.id_categoria = P.id_categoria
INNER JOIN DETALLE_VENTA AS DV
    ON P.id_producto = DV.id_producto
INNER JOIN VENTA AS V
    ON DV.id_venta = V.id_venta
WHERE V.fecha >= '2026-01-01'
  AND V.fecha < '2026-07-01'
GROUP BY C.id_categoria, C.nombre
ORDER BY monto_total_ventas DESC;
GO


/* CASO DE USO 3
   Objetivo: identificar las categorías cuyas ventas superan
   un monto total de $500 durante el año 2026.
   Se utiliza HAVING para filtrar los resultados agrupados.
*/
SELECT
    C.id_categoria,
    C.nombre AS categoria,
    SUM(DV.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT V.id_venta) AS cantidad_ventas,
    SUM(DV.cantidad * DV.precio_unitario) AS monto_total_ventas
FROM CATEGORIA AS C
INNER JOIN PRODUCTO AS P
    ON C.id_categoria = P.id_categoria
INNER JOIN DETALLE_VENTA AS DV
    ON P.id_producto = DV.id_producto
INNER JOIN VENTA AS V
    ON DV.id_venta = V.id_venta
WHERE V.fecha >= '2026-01-01'
  AND V.fecha < '2027-01-01'
GROUP BY C.id_categoria, C.nombre
HAVING SUM(DV.cantidad * DV.precio_unitario) > 500
ORDER BY monto_total_ventas DESC;
GO
