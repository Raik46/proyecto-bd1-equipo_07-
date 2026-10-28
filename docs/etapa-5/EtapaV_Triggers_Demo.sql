USE techgamer;
GO

-- ============================================================================
-- ETAPA V - DEMOSTRACIÓN DE TRIGGERS DE AUDITORÍA
-- Ejecutar después de EtapaV_Procedimientos_Funciones.sql y
-- EtapaV_Triggers_Auditoria.sql
-- ============================================================================

-- 1) Venta con el procedimiento (el cliente 5 ya acumuló $620.000: 10% de descuento).
--    Audita: INSERT en VENTA, INSERT en DETALLE_VENTA y UPDATE de stock en PRODUCTO.
EXEC dbo.sp_RegistrarVentaCompleta
     @id_cliente = 5, @id_empleado = 1, @id_forma_pago = 1,
     @id_producto = 2, @cantidad = 2;
GO

-- 2) Cambio de precio manual
UPDATE dbo.PRODUCTO SET precio = 50000.00 WHERE id_producto = 1;
GO

-- 3) Cambio sobre una venta
UPDATE dbo.VENTA SET id_forma_pago = 3 WHERE id_venta = 1;
GO

-- 4) Borrado de una venta dentro de una transacción (se revierte para no perder datos).
--    El borrado en cascada de DETALLE_VENTA también queda auditado.
BEGIN TRANSACTION;
    DELETE FROM dbo.VENTA WHERE id_venta = 2;
    SELECT * FROM dbo.AUDITORIA ORDER BY id_auditoria DESC;
ROLLBACK TRANSACTION;
GO

-- 5) Auditoría completa
SELECT * FROM dbo.AUDITORIA ORDER BY id_auditoria;
GO

-- 6) Intento de alterar la auditoría (debe fallar)
DELETE FROM dbo.AUDITORIA;
GO
