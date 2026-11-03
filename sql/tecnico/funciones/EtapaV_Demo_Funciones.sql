
USE techgamer;
GO


-- 1) descuento de todos los clientes, junto con lo que acumulo cada uno
SELECT c.id_cliente,
       c.nombre,
       c.apellido,
       ISNULL(SUM(v.total), 0) AS total_acumulado,
       dbo.fn_CalcularDescuentoCliente(c.id_cliente) AS descuento
FROM dbo.CLIENTE c
LEFT JOIN dbo.VENTA v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY c.id_cliente;
GO

-- 2) llamada directa para un cliente (el 5 deberia dar 0.10)
SELECT dbo.fn_CalcularDescuentoCliente(5) AS descuento_cliente_5;
GO

-- 3) un cliente que no existe no tiene ventas, asi que da 0
SELECT dbo.fn_CalcularDescuentoCliente(99999) AS descuento_cliente_inexistente;
GO

-- 4) los limites: la comparacion es "mayor a", asi que justo 200.000 y justo 500.000 no suben de escalon
BEGIN TRANSACTION;

    INSERT INTO dbo.CLIENTE (nombre, apellido, dni, email, telefono)
    VALUES ('Prueba', 'Limites', '99999999', 'prueba@email.com', '1100000000');

    DECLARE @id INT = SCOPE_IDENTITY();

    PRINT '--- sin ventas ---';
    SELECT dbo.fn_CalcularDescuentoCliente(@id) AS descuento;            -- 0.00

    INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES (GETDATE(), 200000.00, @id, 1, 1);

    PRINT '--- justo 200.000 ---';
    SELECT dbo.fn_CalcularDescuentoCliente(@id) AS descuento;            -- 0.00

    INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES (GETDATE(), 0.01, @id, 1, 1);

    PRINT '--- 200.000,01 ---';
    SELECT dbo.fn_CalcularDescuentoCliente(@id) AS descuento;            -- 0.05

    INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES (GETDATE(), 299999.99, @id, 1, 1);

    PRINT '--- justo 500.000 ---';
    SELECT dbo.fn_CalcularDescuentoCliente(@id) AS descuento;            -- 0.05

    INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES (GETDATE(), 0.01, @id, 1, 1);

    PRINT '--- 500.000,01 ---';
    SELECT dbo.fn_CalcularDescuentoCliente(@id) AS descuento;            -- 0.10

ROLLBACK TRANSACTION;
GO

-- 5) la funcion tambien se puede usar para calcular un precio con descuento
SELECT c.id_cliente,
       c.apellido,
       p.nombre AS producto,
       p.precio,
       p.precio * (1 - dbo.fn_CalcularDescuentoCliente(c.id_cliente)) AS precio_con_descuento
FROM dbo.CLIENTE c
CROSS JOIN dbo.PRODUCTO p
WHERE c.id_cliente = 5 AND p.id_producto = 2;
GO
