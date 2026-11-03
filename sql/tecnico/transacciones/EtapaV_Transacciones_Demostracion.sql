USE techgamer;
GO

SET NOCOUNT ON;

DECLARE @cli INT, @emp INT, @fp INT;
DECLARE @prodA INT, @prodB INT;
DECLARE @stockA_antes INT, @stockB_antes INT;
DECLARE @ventas_antes INT, @id_venta INT;
DECLARE @detalle dbo.TipoDetalleVenta;
DECLARE @stock_tmp INT;

SELECT TOP 1 @cli = id_cliente, @emp = id_empleado, @fp = id_forma_pago
FROM dbo.VENTA;

SELECT TOP 1 @prodA = id_producto FROM dbo.PRODUCTO WHERE stock >= 5 ORDER BY id_producto;
SELECT TOP 1 @prodB = id_producto FROM dbo.PRODUCTO WHERE stock >= 5 AND id_producto <> @prodA ORDER BY id_producto;

IF @cli IS NULL OR @prodA IS NULL OR @prodB IS NULL
BEGIN
    RAISERROR('Faltan datos de prueba (ventas o productos con stock >= 5).', 16, 1);
    RETURN;
END

PRINT '=== Datos de prueba: cliente ' + CAST(@cli AS VARCHAR(10))
    + ' | productos ' + CAST(@prodA AS VARCHAR(10)) + ' y ' + CAST(@prodB AS VARCHAR(10));

PRINT '';
PRINT '=== DEMO 1: venta correcta (COMMIT) ===';

SELECT @stockA_antes = stock FROM dbo.PRODUCTO WHERE id_producto = @prodA;
SELECT @stockB_antes = stock FROM dbo.PRODUCTO WHERE id_producto = @prodB;

INSERT INTO @detalle (id_producto, cantidad) VALUES (@prodA, 2), (@prodB, 1);

EXEC dbo.sp_RegistrarVentaMultiple
     @id_cliente = @cli, @id_empleado = @emp, @id_forma_pago = @fp,
     @detalle = @detalle, @id_venta = @id_venta OUTPUT;

PRINT 'Venta registrada. ID Venta: ' + CAST(@id_venta AS VARCHAR(10));

SELECT 'Cabecera' AS tabla, v.id_venta, v.total, v.fecha
FROM dbo.VENTA v WHERE v.id_venta = @id_venta;

SELECT 'Detalle' AS tabla, dv.id_venta, dv.id_producto, dv.cantidad, dv.precio_unitario
FROM dbo.DETALLE_VENTA dv WHERE dv.id_venta = @id_venta;

SELECT p.id_producto,
       CASE p.id_producto WHEN @prodA THEN @stockA_antes ELSE @stockB_antes END AS stock_antes,
       p.stock AS stock_despues
FROM dbo.PRODUCTO p WHERE p.id_producto IN (@prodA, @prodB);

PRINT '';
PRINT '=== DEMO 2: falla a mitad de la venta (ROLLBACK automático) ===';

DELETE FROM @detalle;
INSERT INTO @detalle (id_producto, cantidad) VALUES (@prodA, 1), (@prodB, 999999);

SELECT @ventas_antes = COUNT(*) FROM dbo.VENTA;
SELECT @stockA_antes = stock FROM dbo.PRODUCTO WHERE id_producto = @prodA;
SET @id_venta = NULL;

BEGIN TRY
    EXEC dbo.sp_RegistrarVentaMultiple
         @id_cliente = @cli, @id_empleado = @emp, @id_forma_pago = @fp,
         @detalle = @detalle, @id_venta = @id_venta OUTPUT;
    PRINT 'ERROR DE DEMO: la venta no debió registrarse.';
END TRY
BEGIN CATCH
    PRINT 'Error capturado (esperado): ' + ERROR_MESSAGE();
END CATCH

SELECT (SELECT COUNT(*) FROM dbo.VENTA) - @ventas_antes AS ventas_nuevas_esperado_0,
       @stockA_antes AS stock_A_antes,
       (SELECT stock FROM dbo.PRODUCTO WHERE id_producto = @prodA) AS stock_A_despues_igual,
       @@TRANCOUNT AS transacciones_abiertas_esperado_0;

PRINT '';
PRINT '=== DEMO 3: ROLLBACK manual ===';

SELECT @stockA_antes = stock FROM dbo.PRODUCTO WHERE id_producto = @prodA;

BEGIN TRANSACTION;
    UPDATE dbo.PRODUCTO SET stock = stock - 3 WHERE id_producto = @prodA;
    SELECT @stock_tmp = stock FROM dbo.PRODUCTO WHERE id_producto = @prodA;
    PRINT 'Dentro de la transacción (@@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5)) + '): '
        + 'stock = ' + CAST(@stock_tmp AS VARCHAR(10));
ROLLBACK TRANSACTION;

SELECT @stock_tmp = stock FROM dbo.PRODUCTO WHERE id_producto = @prodA;
PRINT 'Después del ROLLBACK: stock = ' + CAST(@stock_tmp AS VARCHAR(10))
    + ' (original: ' + CAST(@stockA_antes AS VARCHAR(10)) + ')';

PRINT '';
PRINT '=== DEMO 4: SAVE TRANSACTION (punto de control parcial) ===';

SELECT @stockA_antes = stock FROM dbo.PRODUCTO WHERE id_producto = @prodA;
SELECT @stockB_antes = stock FROM dbo.PRODUCTO WHERE id_producto = @prodB;

BEGIN TRANSACTION;
    UPDATE dbo.PRODUCTO SET stock = stock - 1 WHERE id_producto = @prodA;

    SAVE TRANSACTION punto_A;

    UPDATE dbo.PRODUCTO SET stock = stock - 1 WHERE id_producto = @prodB;

    ROLLBACK TRANSACTION punto_A;
COMMIT TRANSACTION;

SELECT 'A (bajó 1: confirmado)' AS producto, @stockA_antes AS antes,
       (SELECT stock FROM dbo.PRODUCTO WHERE id_producto = @prodA) AS despues
UNION ALL
SELECT 'B (sin cambios: revertido)', @stockB_antes,
       (SELECT stock FROM dbo.PRODUCTO WHERE id_producto = @prodB);

UPDATE dbo.PRODUCTO SET stock = stock + 1 WHERE id_producto = @prodA;

PRINT '';
PRINT '=== DEMO 5: producto inexistente y detalle vacío ===';

DELETE FROM @detalle;
INSERT INTO @detalle (id_producto, cantidad) VALUES (-1, 1);
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaMultiple @cli, @emp, @fp, @detalle, @id_venta OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Producto inexistente -> ' + ERROR_MESSAGE();
END CATCH

DELETE FROM @detalle;
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaMultiple @cli, @emp, @fp, @detalle, @id_venta OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Detalle vacío -> ' + ERROR_MESSAGE();
END CATCH
GO
