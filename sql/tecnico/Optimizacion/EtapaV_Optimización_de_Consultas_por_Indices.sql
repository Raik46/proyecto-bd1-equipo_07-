USE techgamer;
GO

IF OBJECT_ID('dbo.VENTA_PRUEBA', 'U') IS NOT NULL DROP TABLE dbo.VENTA_PRUEBA;
GO

CREATE TABLE dbo.VENTA_PRUEBA (
    id_venta      INT IDENTITY(1,1) NOT NULL,
    fecha         DATETIME      NOT NULL,
    total         DECIMAL(12,2) NOT NULL,
    id_cliente    INT           NOT NULL,
    id_empleado   INT           NOT NULL,
    id_forma_pago INT           NOT NULL,
    CONSTRAINT PK_VENTA_PRUEBA PRIMARY KEY CLUSTERED (id_venta)
);
GO

PRINT 'Iniciando carga masiva de 1,000,000 de ventas...';
GO
SET NOCOUNT ON;

-- Utilizamos un CTE en cascada (Tally Table) para generar 1 millón de filas rápidamente
WITH
  L0   AS (SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS (SELECT 1 AS c FROM L0 A CROSS JOIN L0 B),
  L2   AS (SELECT 1 AS c FROM L1 A CROSS JOIN L1 B),
  L3   AS (SELECT 1 AS c FROM L2 A CROSS JOIN L2 B),
  L4   AS (SELECT 1 AS c FROM L3 A CROSS JOIN L3 B),
  L5   AS (SELECT 1 AS c FROM L4 A CROSS JOIN L4 B),
  Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
INSERT INTO dbo.VENTA_PRUEBA (fecha, total, id_cliente, id_empleado, id_forma_pago)
SELECT TOP (1000000)
    DATEADD(minute, n, '20200101'), -- Fechas incrementales espaciadas por minutos
    CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(12,2)),
    1, 1, 1
FROM Nums;
GO
SET NOCOUNT OFF;
PRINT 'Carga masiva finalizada.';
GO

SET STATISTICS IO, TIME ON;
GO
-- Limpiamos caché de planes y datos para que la prueba no se beneficie de ejecuciones previas (solo entornos de prueba)
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

PRINT '--- PRUEBA 1: SIN ÍNDICE ESPECÍFICO EN FECHA (Table / Clustered Index Scan) ---';
SELECT id_venta, fecha, total
FROM dbo.VENTA_PRUEBA
WHERE fecha >= '20210101' AND fecha < '20220101';
GO
SET STATISTICS IO, TIME OFF;
GO

-- Cambiamos la PK a NONCLUSTERED
ALTER TABLE dbo.VENTA_PRUEBA DROP CONSTRAINT PK_VENTA_PRUEBA;
ALTER TABLE dbo.VENTA_PRUEBA ADD CONSTRAINT PK_VENTA_PRUEBA PRIMARY KEY NONCLUSTERED (id_venta);
GO

-- Creamos el Índice Agrupado en Fecha
CREATE CLUSTERED INDEX CIX_VENTA_PRUEBA_fecha ON dbo.VENTA_PRUEBA(fecha);
GO

SET STATISTICS IO, TIME ON;
GO
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

PRINT '--- PRUEBA 2: CON ÍNDICE AGRUPADO EN FECHA (Clustered Index Seek) ---';
SELECT id_venta, fecha, total
FROM dbo.VENTA_PRUEBA
WHERE fecha >= '20210101' AND fecha < '20220101';
GO
SET STATISTICS IO, TIME OFF;
GO

DROP INDEX CIX_VENTA_PRUEBA_fecha ON dbo.VENTA_PRUEBA;
GO

CREATE NONCLUSTERED INDEX NCIX_VENTA_PRUEBA_fecha_inc ON dbo.VENTA_PRUEBA(fecha) INCLUDE (id_venta, total);
GO

SET STATISTICS IO, TIME ON;
GO
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

PRINT '--- PRUEBA 3: CON ÍNDICE NO AGRUPADO + INCLUDE (Index Seek - Covering Index) ---';
SELECT id_venta, fecha, total
FROM dbo.VENTA_PRUEBA
WHERE fecha >= '20210101' AND fecha < '20220101';
GO
SET STATISTICS IO, TIME OFF;
GO

DROP TABLE dbo.VENTA_PRUEBA;
GO
