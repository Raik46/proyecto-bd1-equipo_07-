USE techgamer;
GO

SELECT
    v.id_venta AS numero_venta,
    v.fecha AS fecha_venta,
    c.nombre + ' ' + c.apellido AS cliente,
    e.nombre + ' ' + e.apellido AS empleado,
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario,
    dv.cantidad * dv.precio_unitario AS subtotal_renglon,
    SUM(dv.cantidad * dv.precio_unitario) OVER (
        PARTITION BY v.id_venta
        ORDER BY dv.id_detalle
    ) AS total_acumulado
FROM VENTA AS v
INNER JOIN CLIENTE AS c ON c.id_cliente = v.id_cliente
INNER JOIN EMPLEADO AS e ON e.id_empleado = v.id_empleado
INNER JOIN DETALLE_VENTA AS dv ON dv.id_venta = v.id_venta
INNER JOIN PRODUCTO AS p ON p.id_producto = dv.id_producto
WHERE v.id_venta = 1;
GO
