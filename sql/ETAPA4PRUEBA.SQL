-- ETAPA IV - CONSULTAS Y CASOS DE USO
USE techgamer;
GO

-- SECCION 1: Comprobante
-- OBJETIVO: Consolidar encabezado y detalle de una venta especificando sub-totales por renglon y el total...
-- ...acumulado dinamico mediante funciones de ventana.


SELECT
  v.id_venta AS numero_venta,
  v.fecha AS fecha_venta,
  c.nombre + ' ' + c.apellido AS cliente,
  e.nombre + ' ' + e.apellido AS empleado,
  p.nombre AS producto,
  dv.cantidad,
  dv.precio_unitario,
  (dv.cantidad * dv.precio_unitario) AS subtotal_renglon,
  SUM(dv.cantidad * dv.precio_unitario) OVER(
    PARTITION BY v.id_venta
    ORDER BY dv.id_detalle
  ) AS total_acumulado
FROM VENTA v
INNER JOIN CLIENTE c ON v.id_cliente = c.id_cliente
INNER JOIN EMPLEADO e ON v.id_empleado = e.id_empleado
INNER JOIN DETALLE_VENTA dv ON v.id_venta = dv.id_venta
INNER JOIN PRODUCTO p ON dv.id_producto = p.id_producto
WHERE v.id_venta = 1;
GO



-- SECCION 2: Reporte
-- OBJETIVO: Consolidar el total de ventas y unidades por cada categoria de producto dentro...
-- ...de un rango de fechas

SELECT
  cat.id_categoria,
  cat.nombre AS categoria,
  SUM(dv.cantidad) AS unidades_vendidas,
  SUM(dv.cantidad * dv.precio_unitario) AS monto_total_ventas
FROM CATEGORIA cat
INNER JOIN PRODUCTO p ON cat.id_categoria = p.id_categoria
INNER JOIN DETALLE_VENTA dv ON p.id_producto = dv.id_producto
INNER JOIN VENTA v ON dv.id_venta = v.id_venta
WHERE v.fecha >= '2026-01-01T00:00:00'
  AND v.fecha <= '2026-12-31T23:59:59'
GROUP BY cat.id_categoria, cat.nombre
ORDER BY monto_total_ventas DESC;
GO



-- SECCION 3: Consulta de Negocio
-- OBJETIVO: Identificar clientes VIP combinando las tablas CLIENTE y VENTA, aplicando un filtro HAVING...
-- ...que evalua contra el promedio general de ventas.

SELECT
  c.id_cliente,
  c.nombre + ' ' + c.apellido AS cliente,
  COUNT(v.id_venta) AS cantidad_compras,
  SUM(v.total) AS total_gastado
FROM CLIENTE c
INNER JOIN VENTA v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING SUM(v.total) > (
    SELECT AVG(total)
    FROM VENTA
)
ORDER BY total_gastado DESC;
GO
