USE techgamer;
GO

-- ============================================================================
-- 1. FUNCIÓN ALMACENADA: fn_CalcularDescuentoCliente
-- ============================================================================
IF OBJECT_ID('dbo.fn_CalcularDescuentoCliente', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalcularDescuentoCliente;
GO

CREATE FUNCTION dbo.fn_CalcularDescuentoCliente
(
    @id_cliente INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total_acumulado DECIMAL(12,2) = 0.00;
    DECLARE @porcentaje_descuento DECIMAL(5,2) = 0.00;

    SELECT @total_acumulado = ISNULL(SUM(total), 0.00)
    FROM dbo.VENTA
    WHERE id_cliente = @id_cliente;
    IF @total_acumulado > 500000.00
        SET @porcentaje_descuento = 0.10; -- 10%
    ELSE IF @total_acumulado > 200000.00
        SET @porcentaje_descuento = 0.05; -- 5%
    ELSE
        SET @porcentaje_descuento = 0.00; -- 0%

    RETURN @porcentaje_descuento;
END;
GO

-- ============================================================================
-- 2. PROCEDIMIENTO ALMACENADO: sp_RegistrarVentaCompleta
-- ============================================================================
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

    DECLARE @precio_unitario DECIMAL(10,2);
    DECLARE @stock_actual INT;
    DECLARE @descuento DECIMAL(5,2);
    DECLARE @total_calculado DECIMAL(12,2);
    DECLARE @nuevo_id_venta INT;

    -- ------------------------------------------------------------------------
    -- VALIDACIONES DE NEGOCIO
    -- ------------------------------------------------------------------------
    IF @cantidad <= 0
    BEGIN
        RAISERROR('Error: La cantidad vendida debe ser mayor a 0.', 16, 1);
        RETURN;
    END
    SELECT @precio_unitario = precio, @stock_actual = stock
    FROM dbo.PRODUCTO
    WHERE id_producto = @id_producto;
    
    IF @precio_unitario IS NULL
    BEGIN
        RAISERROR('Error: El producto especificado no existe.', 16, 1);
        RETURN;
    END

        IF @stock_actual < @cantidad
    BEGIN
        RAISERROR('Error: Stock insuficiente para realizar la venta.', 16, 1);
        RETURN;
    END

    -- ------------------------------------------------------------------------
    -- OPERACIÓN MULTITABLA (TRANSACCIÓN INTEGRAL)
    -- ------------------------------------------------------------------------
    BEGIN TRANSACTION;
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

    PRINT 'Venta registrada con éxito. ID Venta: ' + CAST(@nuevo_id_venta AS VARCHAR(10));
END;
GO
