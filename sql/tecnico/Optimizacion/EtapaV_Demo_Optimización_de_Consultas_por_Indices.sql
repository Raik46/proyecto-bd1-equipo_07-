

USE techgamer;
GO

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

SET NOCOUNT ON;
INSERT INTO dbo.VENTA_PRUEBA (fecha, total, id_cliente, id_empleado, id_forma_pago)
SELECT TOP (500000)
       DATEADD(MINUTE, -n, GETDATE()),
       ((n % 900) + 100) * 100.00,
       (n % 5000) + 1,
       (n % 8) + 1,
       (n % 8) + 1
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
      FROM sys.all_objects a CROSS JOIN sys.all_objects b CROSS JOIN sys.all_objects c) x;
SET NOCOUNT OFF;
GO

SELECT COUNT(*) AS filas FROM dbo.VENTA_PRUEBA;
GO

-- limpio cache para que no haya trampa (solo en entorno de prueba)
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- prueba A: total de un cliente (es lo que hace fn_CalcularDescuentoCliente)
PRINT '--- A: sin indice ---';
SELECT SUM(total) AS total_cliente
FROM dbo.VENTA_PRUEBA
WHERE id_cliente = 1234;
GO

CREATE NONCLUSTERED INDEX IX_VP_id_cliente
    ON dbo.VENTA_PRUEBA (id_cliente)
    INCLUDE (total);
GO

PRINT '--- A: con indice ---';
SELECT SUM(total) AS total_cliente
FROM dbo.VENTA_PRUEBA
WHERE id_cliente = 1234;
GO

-- prueba B: reporte por rango de fechas
PRINT '--- B: sin indice en fecha ---';
SELECT COUNT(*) AS cantidad, SUM(total) AS monto
FROM dbo.VENTA_PRUEBA
WHERE fecha >= DATEADD(DAY, -2, GETDATE());
GO

CREATE NONCLUSTERED INDEX IX_VP_fecha
    ON dbo.VENTA_PRUEBA (fecha)
    INCLUDE (total);
GO

PRINT '--- B: con indice en fecha ---';
SELECT COUNT(*) AS cantidad, SUM(total) AS monto
FROM dbo.VENTA_PRUEBA
WHERE fecha >= DATEADD(DAY, -2, GETDATE());
GO

-- prueba C: lo mismo pero pidiendo una columna que el indice NO incluye
-- (id_forma_pago), tiene que hacer lookups a la tabla y se nota en las lecturas
PRINT '--- C: indice que no cubre la consulta ---';
SELECT id_venta, fecha, total, id_forma_pago
FROM dbo.VENTA_PRUEBA
WHERE fecha >= DATEADD(DAY, -2, GETDATE());
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- fragmentacion de los indices de prueba
SELECT i.name AS indice,
       ps.avg_fragmentation_in_percent AS fragmentacion,
       ps.page_count AS paginas
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.VENTA_PRUEBA'), NULL, NULL, 'LIMITED') ps
JOIN sys.indexes i ON i.object_id = ps.object_id AND i.index_id = ps.index_id
WHERE i.name IS NOT NULL;
GO

-- regla comun: de 5 a 30% se reorganiza, mas de 30% se reconstruye
ALTER INDEX IX_VP_fecha ON dbo.VENTA_PRUEBA REORGANIZE;
ALTER INDEX IX_VP_id_cliente ON dbo.VENTA_PRUEBA REBUILD;
GO

DROP TABLE dbo.VENTA_PRUEBA;
GO
