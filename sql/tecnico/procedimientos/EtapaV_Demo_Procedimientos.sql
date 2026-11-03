
USE techgamer;
GO

BEGIN TRANSACTION;

    PRINT '--- stock antes ---';
    SELECT id_producto, nombre, stock FROM dbo.PRODUCTO WHERE id_producto = 2;

    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 5, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 2, @cantidad = 2;

    PRINT '--- venta creada ---';
    SELECT TOP 1 id_venta, fecha, total, id_cliente, id_empleado, id_forma_pago
    FROM dbo.VENTA ORDER BY id_venta DESC;

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

PRINT '--- cantidad negativa ---';
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 1, @cantidad = -3;
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
-- el stock del producto 10 sigue en 5 y la cantidad de ventas es la misma que antes
SELECT id_producto, nombre, stock FROM dbo.PRODUCTO WHERE id_producto = 10;
SELECT COUNT(*) AS cantidad_de_ventas FROM dbo.VENTA;
GO

-- comprar justo todo el stock si se puede (5 sillas), tambien con rollback
BEGIN TRANSACTION;

    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 10, @cantidad = 5;

    PRINT '--- stock despues de comprar todo (tiene que ser 0) ---';
    SELECT id_producto, nombre, stock FROM dbo.PRODUCTO WHERE id_producto = 10;

ROLLBACK TRANSACTION;
GO
