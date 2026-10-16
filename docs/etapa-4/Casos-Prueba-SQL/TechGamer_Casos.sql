USE techgamer;
GO

BEGIN TRANSACTION;

-- 1. CARGA DE DATOS DE PRUEBA CONTROLADOS

-- Categorías (Incluye una sin ventas para probar exclusión en INNER JOIN)
INSERT INTO CATEGORIA (id_categoria, nombre) VALUES
(1, 'Placas de Video'),
(2, 'Periféricos'),
(3, 'Monitores (Sin Ventas)');

-- Productos
INSERT INTO PRODUCTO (id_producto, nombre, precio, stock, id_categoria) VALUES
(101, 'RTX 4070', 1000.00, 10, 1),
(102, 'Teclado Mecánico', 100.00, 50, 2),
(103, 'Mouse Gamer', 50.00, 50, 2);

-- Clientes
-- Cliente 1: Comprador fuerte (1 compra grande + 1 en el límite de fecha)
-- Cliente 2: Comprador frecuente (varias compras chicas que sumadas superan el promedio)
-- Cliente 3: Comprador ocasional (por debajo del promedio, NO debe ser VIP)
INSERT INTO CLIENTE (id_cliente, nombre, apellido, email) VALUES
(1, 'Ana', 'Gómez', 'ana@test.com'),
(2, 'Bruno', 'Díaz', 'bruno@test.com'),
(3, 'Carlos', 'López', 'carlos@test.com');

-- Empleado
INSERT INTO EMPLEADO (id_empleado, nombre, apellido) VALUES
(1, ' Martín', 'Palermo');

-- Ventas
-- Promedio esperado de todas las ventas (6 ventas):
-- (1250 + 300 + 300 + 300 + 100 + 150) / 6 = 2400 / 6 = 400.00
INSERT INTO VENTA (id_venta, fecha, id_cliente, id_empleado, total) VALUES
-- Venta 1: Caso principal Sección 1 y límite inferior exacto 2026 (Total: 1250)
(1, '2026-01-01T00:00:00', 1, 1, 1250.00),
-- Ventas 2, 3 y 4: Cliente 2 acumula 900 en 3 compras de 300 (supera el AVG de 400)
(2, '2026-05-10T14:30:00', 2, 1, 300.00),
(3, '2026-06-15T10:00:00', 2, 1, 300.00),
(4, '2026-12-31T23:59:59', 2, 1, 300.00), -- Límite superior exacto 2026
-- Venta 5: Cliente 3 con compra baja en 2026 (Total: 100 -> NO es VIP)
(5, '2026-08-20T18:00:00', 3, 1, 100.00),
-- Venta 6: Venta fuera de rango (Año 2025) para probar que Sección 2 la excluya
(6, '2025-12-31T23:59:59', 3, 1, 150.00);

-- Detalle de Ventas
INSERT INTO DETALLE_VENTA (id_detalle, id_venta, id_producto, cantidad, precio_unitario) VALUES
-- Renglones de la Venta 1 (Subtotales: 1000, 200, 50 -> Acumulado: 1000, 1200, 1250)
(1, 1, 101, 1, 1000.00),
(2, 1, 102, 2, 100.00),
(3, 1, 103, 1, 50.00),
-- Renglones de Ventas 2, 3 y 4 (Periféricos en 2026)
(4, 2, 102, 3, 100.00),
(5, 3, 102, 3, 100.00),
(6, 4, 102, 3, 100.00),
-- Renglón de Venta 5 (Periféricos en 2026)
(7, 5, 103, 2, 50.00),
-- Renglón de Venta 6 (Año 2025 - NO debe contarse en el reporte de 2026)
(8, 6, 103, 3, 50.00);


-- 2. EJECUCIÓN Y VALIDACIÓN DE RESULTADOS ESPERADOS

-- PRUEBA SECCIÓN 1:
-- Resultado esperado para id_venta = 1:
-- Renglón 1: subtotal = 1000.00 | total_acumulado = 1000.00
-- Renglón 2: subtotal =  200.00 | total_acumulado = 1200.00
-- Renglón 3: subtotal =   50.00 | total_acumulado = 1250.00
SELECT
  v.id_venta AS numero_venta,
  v.fecha AS fecha_venta,
  c.nombre + ' ' + c.apellido AS cliente,
  p.nombre AS producto,
  dv.cantidad,
  dv.precio_unitario,
  (dv.cantidad * dv.precio_unitario) AS subtotal_renglon,
  SUM(dv.cantidad * dv.precio_unitario) OVER(
    PARTITION BY v.id_venta
    ORDER BY dv.id_detalle
  ) AS total_acumulado
FROM VENTA v
INNER JOIN CLIENTE c ON v.id_cliente = c.id_cliente
INNER JOIN EMPLEADO e ON v.id_empleado = e.id_empleado
INNER JOIN DETALLE_VENTA dv ON v.id_venta = dv.id_venta
INNER JOIN PRODUCTO p ON dv.id_producto = p.id_producto
WHERE v.id_venta = 1;


-- PRUEBA SECCIÓN 2:
-- Resultado esperado (solo año 2026):
-- 1° 'Periféricos'    -> unidades_vendidas = 14 (2+1+3+3+3+2) | monto_total_ventas = 1250.00
-- 2° 'Placas de Video'-> unidades_vendidas = 1                | monto_total_ventas = 1000.00
-- (La Venta 6 de 2025 por $150 y la Categoría 3 sin ventas NO deben aparecer)
SELECT
  cat.id_categoria,
  cat.nombre AS categoria,
  SUM(dv.cantidad) AS unidades_vendidas,
  SUM(dv.cantidad * dv.precio_unitario) AS monto_total_ventas
FROM CATEGORIA cat
INNER JOIN PRODUCTO p ON cat.id_categoria = p.id_categoria
INNER JOIN DETALLE_VENTA dv ON p.id_producto = dv.id_producto
INNER JOIN VENTA v ON dv.id_venta = v.id_venta
WHERE v.fecha >= '2026-01-01T00:00:00'
  AND v.fecha <= '2026-12-31T23:59:59'
GROUP BY cat.id_categoria, cat.nombre
ORDER BY monto_total_ventas DESC;


-- PRUEBA SECCIÓN 3:
-- Promedio general AVG(total) = 400.00
-- Resultado esperado:
-- 1° Ana Gómez  (id 1) -> cantidad_compras = 1 | total_gastado = 1250.00
-- 2° Bruno Díaz (id 2) -> cantidad_compras = 3 | total_gastado =  900.00
-- (Carlos López acumula 250.00 <= 400.00, por lo que NO debe aparecer)
SELECT
  c.id_cliente,
  c.nombre + ' ' + c.apellido AS cliente,
  COUNT(v.id_venta) AS cantidad_compras,
  SUM(v.total) AS total_gastado
FROM CLIENTE c
INNER JOIN VENTA v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING SUM(v.total) > (
    SELECT AVG(total)
    FROM VENTA
)
ORDER BY total_gastado DESC;

-- Deshacer los datos de prueba al terminar la verificación
ROLLBACK TRANSACTION;
GO
