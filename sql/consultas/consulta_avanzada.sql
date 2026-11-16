USE techgamer;
GO

SELECT
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    COUNT(v.id_venta) AS cantidad_compras,
    SUM(v.total) AS total_gastado
FROM CLIENTE AS c
INNER JOIN VENTA AS v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING SUM(v.total) > (
    SELECT AVG(CAST(total AS DECIMAL(18, 2)))
    FROM VENTA
)
ORDER BY total_gastado DESC;
GO
