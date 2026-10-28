USE techgamer;
GO

-- ============================================================================
-- ETAPA V - TRIGGERS DE AUDITORÍA
-- Tablas auditadas: VENTA, DETALLE_VENTA, PRODUCTO
-- Requiere SQL Server 2016 o superior (FOR JSON).
-- ============================================================================

-- ============================================================================
-- 1. TABLA DE AUDITORÍA
-- ============================================================================
IF OBJECT_ID('dbo.AUDITORIA', 'U') IS NOT NULL
    DROP TABLE dbo.AUDITORIA;
GO

CREATE TABLE dbo.AUDITORIA (
    id_auditoria     INT IDENTITY(1,1) NOT NULL,
    tabla            VARCHAR(50)   NOT NULL,
    operacion        VARCHAR(10)   NOT NULL,
    id_registro      INT           NOT NULL,
    datos_anteriores NVARCHAR(MAX) NULL,
    datos_nuevos     NVARCHAR(MAX) NULL,
    usuario          NVARCHAR(128) NOT NULL,
    host             NVARCHAR(128) NULL,
    fecha            DATETIME2     NOT NULL
);

ALTER TABLE dbo.AUDITORIA
  ADD CONSTRAINT PK_AUDITORIA PRIMARY KEY (id_auditoria),
      CONSTRAINT DF_AUDITORIA_USUARIO DEFAULT SYSTEM_USER FOR usuario,
      CONSTRAINT DF_AUDITORIA_HOST DEFAULT HOST_NAME() FOR host,
      CONSTRAINT DF_AUDITORIA_FECHA DEFAULT SYSDATETIME() FOR fecha,
      CONSTRAINT CK_AUDITORIA_OPERACION CHECK (operacion IN ('INSERT','UPDATE','DELETE'));
GO

-- ============================================================================
-- 2. TRIGGER SOBRE VENTA
-- ============================================================================
IF OBJECT_ID('dbo.trg_Auditoria_Venta', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Auditoria_Venta;
GO

CREATE TRIGGER dbo.trg_Auditoria_Venta
ON dbo.VENTA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA (tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
    SELECT
        'VENTA',
        CASE WHEN i.id_venta IS NOT NULL AND d.id_venta IS NOT NULL THEN 'UPDATE'
             WHEN i.id_venta IS NOT NULL THEN 'INSERT'
             ELSE 'DELETE' END,
        COALESCE(i.id_venta, d.id_venta),
        CASE WHEN d.id_venta IS NULL THEN NULL ELSE
            (SELECT d.fecha, d.total, d.id_cliente, d.id_empleado, d.id_forma_pago
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.id_venta IS NULL THEN NULL ELSE
            (SELECT i.fecha, i.total, i.id_cliente, i.id_empleado, i.id_forma_pago
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_venta = d.id_venta;
END;
GO

-- ============================================================================
-- 3. TRIGGER SOBRE DETALLE_VENTA
-- ============================================================================
IF OBJECT_ID('dbo.trg_Auditoria_DetalleVenta', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Auditoria_DetalleVenta;
GO

CREATE TRIGGER dbo.trg_Auditoria_DetalleVenta
ON dbo.DETALLE_VENTA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA (tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
    SELECT
        'DETALLE_VENTA',
        CASE WHEN i.id_detalle IS NOT NULL AND d.id_detalle IS NOT NULL THEN 'UPDATE'
             WHEN i.id_detalle IS NOT NULL THEN 'INSERT'
             ELSE 'DELETE' END,
        COALESCE(i.id_detalle, d.id_detalle),
        CASE WHEN d.id_detalle IS NULL THEN NULL ELSE
            (SELECT d.cantidad, d.precio_unitario, d.id_venta, d.id_producto
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.id_detalle IS NULL THEN NULL ELSE
            (SELECT i.cantidad, i.precio_unitario, i.id_venta, i.id_producto
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_detalle = d.id_detalle;
END;
GO

-- ============================================================================
-- 4. TRIGGER SOBRE PRODUCTO (altas, bajas y cambios de nombre/precio/stock)
-- ============================================================================
IF OBJECT_ID('dbo.trg_Auditoria_Producto', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Auditoria_Producto;
GO

CREATE TRIGGER dbo.trg_Auditoria_Producto
ON dbo.PRODUCTO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA (tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
    SELECT
        'PRODUCTO',
        CASE WHEN i.id_producto IS NOT NULL AND d.id_producto IS NOT NULL THEN 'UPDATE'
             WHEN i.id_producto IS NOT NULL THEN 'INSERT'
             ELSE 'DELETE' END,
        COALESCE(i.id_producto, d.id_producto),
        CASE WHEN d.id_producto IS NULL THEN NULL ELSE
            (SELECT d.nombre, d.precio, d.stock
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.id_producto IS NULL THEN NULL ELSE
            (SELECT i.nombre, i.precio, i.stock
             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_producto = d.id_producto
    WHERE i.id_producto IS NULL
       OR d.id_producto IS NULL
       OR i.nombre <> d.nombre
       OR i.precio <> d.precio
       OR i.stock  <> d.stock;
END;
GO

-- ============================================================================
-- 5. PROTECCIÓN DE LA TABLA DE AUDITORÍA (solo lectura)
-- ============================================================================
IF OBJECT_ID('dbo.trg_Proteger_Auditoria', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Proteger_Auditoria;
GO

CREATE TRIGGER dbo.trg_Proteger_Auditoria
ON dbo.AUDITORIA
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    RAISERROR('La tabla AUDITORIA es de solo lectura: no se permite modificar ni borrar registros.', 16, 1);
END;
GO
