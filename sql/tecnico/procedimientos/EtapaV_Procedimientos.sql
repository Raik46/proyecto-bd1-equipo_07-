USE techgamer;
GO

IF OBJECT_ID('dbo.sp_RegistrarVentaCompleta', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarVentaCompleta;
GO

CREATE PROCEDURE dbo.sp_RegistrarVentaCompleta
    @id_cliente INT,
    @id_empleado INT,
    @id_forma_pago INT,
    @id_producto INT,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @precio_unitario DECIMAL(10,2);
    DECLARE @stock_actual INT;
    DECLARE @descuento DECIMAL(5,2);
    DECLARE @total_calculado DECIMAL(12,2);
    DECLARE @nuevo_id_venta INT;

    -- VALIDACIONES DE NEGOCIO
    IF @cantidad <= 0
        THROW 50001, 'Error: La cantidad vendida debe ser mayor a 0.', 1;

    -- OPERACIÓN MULTITABLA (TRANSACCIÓN INTEGRAL)
    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @precio_unitario = precio, @stock_actual = stock
        FROM dbo.PRODUCTO WITH (UPDLOCK, HOLDLOCK)
        WHERE id_producto = @id_producto;

        IF @precio_unitario IS NULL
            THROW 50002, 'Error: El producto especificado no existe.', 1;

        IF @stock_actual < @cantidad
            THROW 50003, 'Error: Stock insuficiente para realizar la venta.', 1;

        SET @descuento = dbo.fn_CalcularDescuentoCliente(@id_cliente);
        SET @total_calculado = (@precio_unitario * @cantidad) * (1.00 - @descuento);

        INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
        VALUES (GETDATE(), @total_calculado, @id_cliente, @id_empleado, @id_forma_pago);

        SET @nuevo_id_venta = SCOPE_IDENTITY();

        INSERT INTO dbo.DETALLE_VENTA (cantidad, precio_unitario, id_venta, id_producto)
        VALUES (@cantidad, @precio_unitario, @nuevo_id_venta, @id_producto);

        UPDATE dbo.PRODUCTO
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH

    PRINT 'Venta registrada con éxito. ID Venta: ' + CAST(@nuevo_id_venta AS VARCHAR(10));
END;
GO
