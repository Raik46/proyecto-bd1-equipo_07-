USE techgamer;
GO

-- DEMOSTRACION ALTERNATIVA DE LOS TRIGGERS DE AUDITORIA
-- Ejecutar despues de EtapaV_Triggers_Auditoria_Alternativa.sql.
-- Se buscan identificadores existentes para no depender de IDs fijos.

-- 1. Registrar una venta mediante el procedimiento almacenado.
-- Esto puede generar INSERT en VENTA, INSERT en DETALLE_VENTA
-- y UPDATE en PRODUCTO por la disminucion del stock.
DECLARE @cliente INT, @empleado INT, @pago INT, @producto INT;

SELECT TOP (1) @cliente = id_cliente FROM dbo.CLIENTE ORDER BY id_cliente;
SELECT TOP (1) @empleado = id_empleado FROM dbo.EMPLEADO ORDER BY id_empleado;
SELECT TOP (1) @pago = id_forma_pago FROM dbo.FORMA_PAGO ORDER BY id_forma_pago;
SELECT TOP (1) @producto = id_producto
FROM dbo.PRODUCTO WHERE stock >= 1 ORDER BY id_producto;

EXEC dbo.sp_RegistrarVentaCompleta
    @id_cliente = @cliente,
    @id_empleado = @empleado,
    @id_forma_pago = @pago,
    @id_producto = @producto,
    @cantidad = 1;
GO

-- 2. Modificar el precio de un producto y generar un registro UPDATE.
DECLARE @producto_modificar INT;
SELECT TOP (1) @producto_modificar = id_producto
FROM dbo.PRODUCTO
ORDER BY id_producto;

IF @producto_modificar IS NOT NULL
BEGIN
    UPDATE dbo.PRODUCTO
    SET precio = precio + 100
    WHERE id_producto = @producto_modificar;
END;
GO

-- 3. Modificar una venta existente.
DECLARE @venta_modificar INT;
SELECT TOP (1) @venta_modificar = id_venta
FROM dbo.VENTA
ORDER BY id_venta;

IF @venta_modificar IS NOT NULL
BEGIN
    UPDATE dbo.VENTA
    SET total = total
    WHERE id_venta = @venta_modificar;
END;
GO

-- 4. Eliminar temporalmente un detalle de venta.
-- La transaccion se revierte para conservar los datos originales.
BEGIN TRANSACTION;

DECLARE @detalle_eliminar INT;
SELECT TOP (1) @detalle_eliminar = id_detalle
FROM dbo.DETALLE_VENTA
ORDER BY id_detalle DESC;

IF @detalle_eliminar IS NOT NULL
    DELETE FROM dbo.DETALLE_VENTA
    WHERE id_detalle = @detalle_eliminar;

SELECT TOP (20) *
FROM dbo.AUDITORIA
ORDER BY id_auditoria DESC;

ROLLBACK TRANSACTION;
GO

-- 5. Consultar el historial completo.
SELECT *
FROM dbo.AUDITORIA
ORDER BY id_auditoria DESC;
GO

-- 6. Comprobar que la tabla de auditoria esta protegida.
-- Esta instruccion debe producir un error.
DELETE FROM dbo.AUDITORIA;
GO
