
USE techgamer;
GO

-- descuento por cliente: mas de 500.000 -> 10%, mas de 200.000 -> 5%, el resto 0
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

BEGIN TRANSACTION;

    PRINT '--- stock antes ---';
    SELECT id_producto, nombre, stock FROM dbo.PRODUCTO WHERE id_producto = 2;

    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 5, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 2, @cantidad = 2;

    PRINT '--- venta creada ---';
    SELECT TOP 1 id_venta, fecha, total, id_cliente FROM dbo.VENTA ORDER BY id_venta DESC;

    PRINT '--- detalle ---';
    SELECT TOP 1 id_detalle, cantidad, precio_unitario, id_venta, id_producto
    FROM dbo.DETALLE_VENTA ORDER BY id_detalle DESC;

    PRINT '--- stock despues (bajo en 2) ---';
    SELECT id_producto, nombre, stock FROM dbo.PRODUCTO WHERE id_producto = 2;

ROLLBACK TRANSACTION;
GO

-- casos que tienen que fallar
PRINT '--- cantidad 0 ---';
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 1, @cantidad = 0;
END TRY
BEGIN CATCH
    PRINT 'Rechazada: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '--- producto que no existe ---';
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 999, @cantidad = 1;
END TRY
BEGIN CATCH
    PRINT 'Rechazada: ' + ERROR_MESSAGE();
END CATCH
GO

-- la silla gamer (producto 10) tiene 5 en stock, pido 6
PRINT '--- stock insuficiente ---';
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 10, @cantidad = 6;
END TRY
BEGIN CATCH
    PRINT 'Rechazada: ' + ERROR_MESSAGE();
END CATCH
GO

-- verifico que los rechazos no cambiaron nada
SELECT id_producto, nombre, stock FROM dbo.PRODUCTO WHERE id_producto = 10;
SELECT COUNT(*) AS cantidad_de_ventas FROM dbo.VENTA;
GO
