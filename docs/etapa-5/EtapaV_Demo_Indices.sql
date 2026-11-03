
USE techgamer;
GO

-- primero ver que indices hay (los de PK y UNIQUE los crea solo SQL Server)
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


SELECT nombre, stock, precio
FROM dbo.PRODUCTO
WHERE stock <= 10
ORDER BY stock;
GO

-- indice por clave foranea: ventas de un empleado
SELECT id_venta, fecha, total
FROM dbo.VENTA
WHERE id_empleado = 1;
GO

-- busqueda por apellido y nombre (indice compuesto)
SELECT id_cliente, nombre, apellido
FROM dbo.CLIENTE
WHERE apellido = 'Perez';
GO
