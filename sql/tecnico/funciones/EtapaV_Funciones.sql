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
