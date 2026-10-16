-- ==========================================
-- ETAPA IV: Consultas y Casos de Uso - TechGamer
-- ==========================================


-- ----------------------------------------------------
-- 1. Factura / Comprobante
-- Consulta que consolida el encabezado y detalle de una venta, 
-- calculando sub-totales por renglón y el total acumulado.
-- ----------------------------------------------------
SELECT 
    f.id_factura AS Numero_Factura,
    f.fecha AS Fecha_Venta,
    c.nombre AS Cliente,
    v.nombre AS Vendedor,
    p.nombre AS Producto,
    df.cantidad AS Cantidad,
    df.precio_unitario AS Precio_Unitario,
    (df.cantidad * df.precio_unitario) AS Subtotal_Renglon,
    SUM(df.cantidad * df.precio_unitario) OVER(PARTITION BY f.id_factura ORDER BY df.id_detalle) AS Total_Acumulado
FROM 
    factura f
JOIN 
    cliente c ON f.id_cliente = c.id_cliente
JOIN 
    vendedor v ON f.id_vendedor = v.id_vendedor
JOIN 
    detalle_factura df ON f.id_factura = df.id_factura
JOIN 
    producto p ON df.id_producto = p.id_producto
WHERE 
    f.id_factura = 1;


-- ----------------------------------------------------
-- 2. Reporte Agregado
-- Total de ventas realizadas por cada vendedor o por cada categoría 
-- de producto en un rango de fechas.
-- ----------------------------------------------------

-- Opción A: Ventas por Vendedor
SELECT 
    v.id_vendedor,
    v.nombre AS Vendedor,
    COUNT(f.id_factura) AS Total_Facturas_Emitidas,
    SUM(df.cantidad * df.precio_unitario) AS Monto_Total_Ventas
FROM 
    vendedor v
JOIN 
    factura f ON v.id_vendedor = f.id_vendedor
JOIN 
    detalle_factura df ON f.id_factura = df.id_factura
WHERE 
    f.fecha BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY 
    v.id_vendedor, v.nombre
ORDER BY 
    Monto_Total_Ventas DESC;

-- Opción B: Ventas por Categoría de Producto
SELECT 
    cat.id_categoria,
    cat.nombre AS Categoria,
    SUM(df.cantidad) AS Unidades_Vendidas,
    SUM(df.cantidad * df.precio_unitario) AS Monto_Total_Ventas
FROM 
    categoria cat
JOIN 
    producto p ON cat.id_categoria = p.id_categoria
JOIN 
    detalle_factura df ON p.id_producto = df.id_producto
JOIN 
    factura f ON df.id_factura = f.id_factura
WHERE 
    f.fecha BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY 
    cat.id_categoria, cat.nombre
ORDER BY 
    Monto_Total_Ventas DESC;


-- ----------------------------------------------------
-- 3. Consulta de Negocio Avanzada
-- Combina al menos 3 tablas mediante JOIN y aplica filtros condicionales (HAVING o subconsultas).
-- ----------------------------------------------------
SELECT 
    c.id_cliente,
    c.nombre AS Cliente,
    COUNT(f.id_factura) AS Cantidad_Compras,
    SUM(df.cantidad * df.precio_unitario) AS Total_Gastado
FROM 
    cliente c
JOIN 
    factura f ON c.id_cliente = f.id_cliente
JOIN 
    detalle_factura df ON f.id_factura = df.id_factura
GROUP BY 
    c.id_cliente, c.nombre
HAVING 
    SUM(df.cantidad * df.precio_unitario) > (
        SELECT AVG(sub.total_factura)
        FROM (
            SELECT SUM(df2.cantidad * df2.precio_unitario) AS total_factura
            FROM factura f2
            JOIN detalle_factura df2 ON f2.id_factura = df2.id_factura
            GROUP BY f2.id_factura
        ) sub
    )
ORDER BY 
    Total_Gastado DESC;