USE techgamer;
GO

SELECT
    cat.id_categoria,
    cat.nombre AS categoria,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.cantidad * dv.precio_unitario) AS monto_total_ventas
FROM CATEGORIA AS cat
INNER JOIN PRODUCTO AS p ON p.id_categoria = cat.id_categoria
INNER JOIN DETALLE_VENTA AS dv ON dv.id_producto = p.id_producto
INNER JOIN VENTA AS v ON v.id_venta = dv.id_venta
WHERE v.fecha >= '2026-01-01T00:00:00'
  AND v.fecha < '2027-01-01T00:00:00'
GROUP BY cat.id_categoria, cat.nombre
ORDER BY monto_total_ventas DESC;
GO
