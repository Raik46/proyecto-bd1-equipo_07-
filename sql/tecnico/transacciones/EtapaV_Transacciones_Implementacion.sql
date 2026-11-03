USE techgamer;
GO

IF TYPE_ID('dbo.TipoDetalleVenta') IS NOT NULL
BEGIN
    IF OBJECT_ID('dbo.sp_RegistrarVentaMultiple', 'P') IS NOT NULL
        DROP PROCEDURE dbo.sp_RegistrarVentaMultiple;
    DROP TYPE dbo.TipoDetalleVenta;
END
GO

CREATE TYPE dbo.TipoDetalleVenta AS TABLE
(
    id_producto INT NOT NULL PRIMARY KEY,
    cantidad    INT NOT NULL CHECK (cantidad > 0)
);
GO

IF OBJECT_ID('dbo.sp_RegistrarVentaMultiple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarVentaMultiple;
GO

CREATE PROCEDURE dbo.sp_RegistrarVentaMultiple
    @id_cliente    INT,
    @id_empleado   INT,
    @id_forma_pago INT,
    @detalle       dbo.TipoDetalleVenta READONLY,
    @id_venta      INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @descuento DECIMAL(5,2);
    DECLARE @subtotal  DECIMAL(12,2);
    DECLARE @total     DECIMAL(12,2);

    IF NOT EXISTS (SELECT 1 FROM @detalle)
        THROW 50001, 'La venta debe contener al menos un producto.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1
                   FROM @detalle d
                   LEFT JOIN dbo.PRODUCTO p WITH (UPDLOCK, HOLDLOCK)
                          ON p.id_producto = d.id_producto
                   WHERE p.id_producto IS NULL)
            THROW 50002, 'Error: al menos uno de los productos no existe.', 1;

        IF EXISTS (SELECT 1
                   FROM @detalle d
                   JOIN dbo.PRODUCTO p WITH (UPDLOCK, HOLDLOCK)
                     ON p.id_producto = d.id_producto
                   WHERE p.stock < d.cantidad)
            THROW 50003, 'Error: stock insuficiente en al menos un producto.', 1;

        SELECT @subtotal = SUM(p.precio * d.cantidad)
        FROM @detalle d
        JOIN dbo.PRODUCTO p ON p.id_producto = d.id_producto;

        SET @descuento = dbo.fn_CalcularDescuentoCliente(@id_cliente);
        SET @total     = @subtotal * (1.00 - @descuento);

        INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
        VALUES (GETDATE(), @total, @id_cliente, @id_empleado, @id_forma_pago);

        SET @id_venta = SCOPE_IDENTITY();

        INSERT INTO dbo.DETALLE_VENTA (cantidad, precio_unitario, id_venta, id_producto)
        SELECT d.cantidad, p.precio, @id_venta, d.id_producto
        FROM @detalle d
        JOIN dbo.PRODUCTO p ON p.id_producto = d.id_producto;

        UPDATE p
        SET    p.stock = p.stock - d.cantidad
        FROM   dbo.PRODUCTO p
        JOIN   @detalle d ON d.id_producto = p.id_producto;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @id_venta = NULL;

        THROW;
    END CATCH
END;
GO
