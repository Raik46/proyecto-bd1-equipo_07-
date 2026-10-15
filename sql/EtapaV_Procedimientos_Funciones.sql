USE techgamer;
GO

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
    FROM VENTA
    WHERE id_cliente = @id_cliente;

    IF @total_acumulado > 500000.00
        SET @porcentaje_descuento = 0.10;
    ELSE IF @total_acumulado > 200000.00
        SET @porcentaje_descuento = 0.05;
    ELSE
        SET @porcentaje_descuento = 0.00;

    RETURN @porcentaje_descuento;
END;
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

    DECLARE @precio_unitario DECIMAL(10,2);
    DECLARE @stock_actual INT;
    DECLARE @total_calculado DECIMAL(12,2);
    DECLARE @descuento DECIMAL(5,2);
    DECLARE @nuevo_id_venta INT;

    SELECT @precio_unitario = precio, @stock_actual = stock
    FROM PRODUCTO
    WHERE id_producto = @id_producto;

    IF @precio_unitario IS NULL
    BEGIN
        PRINT 'Error: El producto especificado no existe.';
        RETURN;
    END

    IF @stock_actual < @cantidad
    BEGIN
        PRINT 'Error: Stock insuficiente para realizar la venta.';
        RETURN;
    END

    SET @descuento = dbo.fn_CalcularDescuentoCliente(@id_cliente);

    SET @total_calculado = (@precio_unitario * @cantidad) * (1.00 - @descuento);

    INSERT INTO VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES (GETDATE(), @total_calculado, @id_cliente, @id_empleado, @id_forma_pago);

    SET @nuevo_id_venta = SCOPE_IDENTITY();

    INSERT INTO DETALLE_VENTA (cantidad, precio_unitario, id_venta, id_producto)
    VALUES (@cantidad, @precio_unitario, @nuevo_id_venta, @id_producto);

    UPDATE PRODUCTO
    SET stock = stock - @cantidad
    WHERE id_producto = @id_producto;

    PRINT 'Venta registrada con exito. ID Venta: ' + CAST(@nuevo_id_venta AS VARCHAR);
END;
GO

SELECT
    id_cliente,
    nombre + ' ' + apellido AS cliente,
    dbo.fn_CalcularDescuentoCliente(id_cliente) AS porcentaje_descuento
FROM CLIENTE;
GO

SELECT id_producto, nombre, stock FROM PRODUCTO WHERE id_producto = 1;

EXEC dbo.sp_RegistrarVentaCompleta
    @id_cliente = 1,
    @id_empleado = 1,
    @id_forma_pago = 1,
    @id_producto = 1,
    @cantidad = 2;

SELECT TOP 1 * FROM VENTA ORDER BY id_venta DESC;
SELECT TOP 1 * FROM DETALLE_VENTA ORDER BY id_detalle DESC;
SELECT id_producto, nombre, stock FROM PRODUCTO WHERE id_producto = 1;
GO
