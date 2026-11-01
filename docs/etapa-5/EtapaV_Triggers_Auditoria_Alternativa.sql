USE techgamer;
GO

-- AUDITORIA ALTERNATIVA
-- Registra INSERT, UPDATE y DELETE en VENTA, DETALLE_VENTA y PRODUCTO.
-- A diferencia de la version anterior, no elimina la tabla de auditoria
-- si ya existe, para evitar perder el historial.

IF OBJECT_ID('dbo.AUDITORIA', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AUDITORIA (
        id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
        tabla VARCHAR(50) NOT NULL,
        operacion VARCHAR(10) NOT NULL,
        id_registro INT NOT NULL,
        datos_anteriores NVARCHAR(MAX) NULL,
        datos_nuevos NVARCHAR(MAX) NULL,
        usuario NVARCHAR(128) NOT NULL
            CONSTRAINT DF_AUDITORIA_V2_USUARIO DEFAULT SYSTEM_USER,
        fecha DATETIME2 NOT NULL
            CONSTRAINT DF_AUDITORIA_V2_FECHA DEFAULT SYSDATETIME(),
        CONSTRAINT CK_AUDITORIA_V2_OPERACION
            CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE'))
    );
END;
GO

-- Trigger para VENTA
CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Venta
ON dbo.VENTA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA
        (tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
    SELECT
        'VENTA',
        CASE
            WHEN d.id_venta IS NULL THEN 'INSERT'
            WHEN i.id_venta IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,
        COALESCE(i.id_venta, d.id_venta),
        CASE WHEN d.id_venta IS NULL THEN NULL ELSE
            (SELECT d.fecha, d.total, d.id_cliente, d.id_empleado,
                    d.id_forma_pago
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        END,
        CASE WHEN i.id_venta IS NULL THEN NULL ELSE
            (SELECT i.fecha, i.total, i.id_cliente, i.id_empleado,
                    i.id_forma_pago
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        END
    FROM inserted AS i
    FULL OUTER JOIN deleted AS d
        ON i.id_venta = d.id_venta;
END;
GO

-- Trigger para DETALLE_VENTA
CREATE OR ALTER TRIGGER dbo.trg_Auditoria_DetalleVenta
ON dbo.DETALLE_VENTA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA
        (tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
    SELECT
        'DETALLE_VENTA',
        CASE
            WHEN d.id_detalle IS NULL THEN 'INSERT'
            WHEN i.id_detalle IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,
        COALESCE(i.id_detalle, d.id_detalle),
        CASE WHEN d.id_detalle IS NULL THEN NULL ELSE
            (SELECT d.cantidad, d.precio_unitario, d.id_venta,
                    d.id_producto
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        END,
        CASE WHEN i.id_detalle IS NULL THEN NULL ELSE
            (SELECT i.cantidad, i.precio_unitario, i.id_venta,
                    i.id_producto
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        END
    FROM inserted AS i
    FULL OUTER JOIN deleted AS d
        ON i.id_detalle = d.id_detalle;
END;
GO

-- Trigger para PRODUCTO
-- Solo registra UPDATE cuando cambia nombre, precio o stock.
CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Producto
ON dbo.PRODUCTO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA
        (tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
    SELECT
        'PRODUCTO',
        CASE
            WHEN d.id_producto IS NULL THEN 'INSERT'
            WHEN i.id_producto IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,
        COALESCE(i.id_producto, d.id_producto),
        CASE WHEN d.id_producto IS NULL THEN NULL ELSE
            (SELECT d.nombre, d.precio, d.stock
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        END,
        CASE WHEN i.id_producto IS NULL THEN NULL ELSE
            (SELECT i.nombre, i.precio, i.stock
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        END
    FROM inserted AS i
    FULL OUTER JOIN deleted AS d
        ON i.id_producto = d.id_producto
    WHERE
        i.id_producto IS NULL
        OR d.id_producto IS NULL
        OR EXISTS (
            SELECT i.nombre, i.precio, i.stock
            EXCEPT
            SELECT d.nombre, d.precio, d.stock
        );
END;
GO

-- Proteccion de la tabla de auditoria
CREATE OR ALTER TRIGGER dbo.trg_Proteger_Auditoria
ON dbo.AUDITORIA
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    THROW 50001,
        'La tabla AUDITORIA es de solo lectura: no se permite modificar ni borrar registros.',
        1;
END;
GO
