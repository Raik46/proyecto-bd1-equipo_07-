USE techgamer;
GO

-- ============================================================================
-- ETAPA V - ÍNDICES (OPTIMIZACIÓN)
--
-- Ya existen índices creados automáticamente por las restricciones:
--   * cada PRIMARY KEY crea un índice agrupado (clustered)
--   * cada UNIQUE crea un índice no agrupado (dni, legajo, cuil, nombre de
--     categoría, descripción de forma de pago, (id_venta, id_producto))
-- SQL Server NO crea índices automáticamente sobre las claves foráneas, por
-- eso se agregan abajo los que aceleran joins, filtros y la función de descuento.
-- ============================================================================

-- ============================================================================
-- 1. ÍNDICES NO AGRUPADOS
-- ============================================================================

-- VENTA: cubre la consulta de fn_CalcularDescuentoCliente (SUM(total) por cliente)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VENTA_id_cliente' AND object_id = OBJECT_ID('dbo.VENTA'))
    DROP INDEX IX_VENTA_id_cliente ON dbo.VENTA;
CREATE NONCLUSTERED INDEX IX_VENTA_id_cliente
    ON dbo.VENTA (id_cliente)
    INCLUDE (total, fecha);

-- VENTA: reportes por rango de fechas
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VENTA_fecha' AND object_id = OBJECT_ID('dbo.VENTA'))
    DROP INDEX IX_VENTA_fecha ON dbo.VENTA;
CREATE NONCLUSTERED INDEX IX_VENTA_fecha
    ON dbo.VENTA (fecha)
    INCLUDE (total, id_cliente, id_empleado);

-- VENTA: ventas por empleado (clave foránea)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VENTA_id_empleado' AND object_id = OBJECT_ID('dbo.VENTA'))
    DROP INDEX IX_VENTA_id_empleado ON dbo.VENTA;
CREATE NONCLUSTERED INDEX IX_VENTA_id_empleado
    ON dbo.VENTA (id_empleado);

-- DETALLE_VENTA: ventas por producto (id_venta ya está cubierto por UQ_DETALLE_VENTA_PRODUCTO)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DETALLE_id_producto' AND object_id = OBJECT_ID('dbo.DETALLE_VENTA'))
    DROP INDEX IX_DETALLE_id_producto ON dbo.DETALLE_VENTA;
CREATE NONCLUSTERED INDEX IX_DETALLE_id_producto
    ON dbo.DETALLE_VENTA (id_producto)
    INCLUDE (cantidad, precio_unitario);

-- PRODUCTO: listado por categoría
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTO_id_categoria' AND object_id = OBJECT_ID('dbo.PRODUCTO'))
    DROP INDEX IX_PRODUCTO_id_categoria ON dbo.PRODUCTO;
CREATE NONCLUSTERED INDEX IX_PRODUCTO_id_categoria
    ON dbo.PRODUCTO (id_categoria)
    INCLUDE (nombre, precio, stock);

-- PRODUCTO: productos por proveedor (clave foránea)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTO_id_proveedor' AND object_id = OBJECT_ID('dbo.PRODUCTO'))
    DROP INDEX IX_PRODUCTO_id_proveedor ON dbo.PRODUCTO;
CREATE NONCLUSTERED INDEX IX_PRODUCTO_id_proveedor
    ON dbo.PRODUCTO (id_proveedor);

-- PRODUCTO: búsqueda por nombre
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTO_nombre' AND object_id = OBJECT_ID('dbo.PRODUCTO'))
    DROP INDEX IX_PRODUCTO_nombre ON dbo.PRODUCTO;
CREATE NONCLUSTERED INDEX IX_PRODUCTO_nombre
    ON dbo.PRODUCTO (nombre);

-- CLIENTE: búsqueda por apellido y nombre (compuesto)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CLIENTE_apellido_nombre' AND object_id = OBJECT_ID('dbo.CLIENTE'))
    DROP INDEX IX_CLIENTE_apellido_nombre ON dbo.CLIENTE;
CREATE NONCLUSTERED INDEX IX_CLIENTE_apellido_nombre
    ON dbo.CLIENTE (apellido, nombre);

-- AUDITORIA: historial de un registro puntual y consultas por fecha
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AUDITORIA_tabla_registro' AND object_id = OBJECT_ID('dbo.AUDITORIA'))
    DROP INDEX IX_AUDITORIA_tabla_registro ON dbo.AUDITORIA;
CREATE NONCLUSTERED INDEX IX_AUDITORIA_tabla_registro
    ON dbo.AUDITORIA (tabla, id_registro)
    INCLUDE (operacion, fecha, usuario);

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AUDITORIA_fecha' AND object_id = OBJECT_ID('dbo.AUDITORIA'))
    DROP INDEX IX_AUDITORIA_fecha ON dbo.AUDITORIA;
CREATE NONCLUSTERED INDEX IX_AUDITORIA_fecha
    ON dbo.AUDITORIA (fecha);
GO

-- ============================================================================
-- 2. ÍNDICE FILTRADO: solo indexa los productos con stock bajo (<= 10)
-- Es más chico y rápido que un índice completo sobre stock.
-- ============================================================================
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PRODUCTO_stock_bajo' AND object_id = OBJECT_ID('dbo.PRODUCTO'))
    DROP INDEX IX_PRODUCTO_stock_bajo ON dbo.PRODUCTO;
CREATE NONCLUSTERED INDEX IX_PRODUCTO_stock_bajo
    ON dbo.PRODUCTO (stock)
    INCLUDE (nombre, precio)
    WHERE stock <= 10;
GO

-- ============================================================================
-- 3. LISTADO DE ÍNDICES CREADOS
-- ============================================================================
SELECT OBJECT_NAME(i.object_id) AS tabla,
       i.name                   AS indice,
       i.type_desc              AS tipo,
       i.is_unique              AS es_unico,
       i.has_filter             AS es_filtrado
FROM sys.indexes i
WHERE i.object_id IN (SELECT object_id FROM sys.tables)
  AND i.name IS NOT NULL
ORDER BY tabla, i.type_desc, i.name;
GO

-- ============================================================================
-- 4. DEMOSTRACIÓN DEL IMPACTO
-- Con solo 10 filas por tabla el motor siempre hace un recorrido completo, así
-- que la mejora no se nota. Para medirla se crea una tabla de prueba con 200.000
-- ventas, se consulta SIN índice y luego CON índice, y se comparan las lecturas
-- lógicas (logical reads: páginas leídas, menos es mejor).
-- La tabla de prueba se elimina al final y no afecta los datos reales.
-- ============================================================================
IF OBJECT_ID('dbo.VENTA_PRUEBA', 'U') IS NOT NULL DROP TABLE dbo.VENTA_PRUEBA;
GO

CREATE TABLE dbo.VENTA_PRUEBA (
    id_venta      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    fecha         DATETIME      NOT NULL,
    total         DECIMAL(12,2) NOT NULL,
    id_cliente    INT           NOT NULL,
    id_empleado   INT           NOT NULL,
    id_forma_pago INT           NOT NULL
);
GO

INSERT INTO dbo.VENTA_PRUEBA (fecha, total, id_cliente, id_empleado, id_forma_pago)
SELECT TOP (200000)
       DATEADD(MINUTE, -n, GETDATE()),
       ((n % 900) + 100) * 100.00,
       (n % 5000) + 1,
       (n % 8) + 1,
       (n % 8) + 1
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
      FROM sys.all_objects a CROSS JOIN sys.all_objects b) numeros;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- 4.1 SIN índice: recorre toda la tabla (Clustered Index Scan)
PRINT '--- SIN INDICE ---';
SELECT SUM(total) AS total_cliente
FROM dbo.VENTA_PRUEBA
WHERE id_cliente = 1234;
GO

-- 4.2 Se crea el índice equivalente a IX_VENTA_id_cliente
CREATE NONCLUSTERED INDEX IX_VENTA_PRUEBA_id_cliente
    ON dbo.VENTA_PRUEBA (id_cliente)
    INCLUDE (total, fecha);
GO

-- 4.3 CON índice: busca directo al cliente (Index Seek)
PRINT '--- CON INDICE ---';
SELECT SUM(total) AS total_cliente
FROM dbo.VENTA_PRUEBA
WHERE id_cliente = 1234;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 4.4 Limpieza
DROP TABLE dbo.VENTA_PRUEBA;
GO

-- 4.5 Índice filtrado: productos con stock bajo (usa IX_PRODUCTO_stock_bajo)
SELECT nombre, stock, precio
FROM dbo.PRODUCTO
WHERE stock <= 10
ORDER BY stock;
GO
