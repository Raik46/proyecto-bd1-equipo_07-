/*
  TechGamer - 3 casos de prueba adicionales
  Basado en el esquema de DDL_techgamer.sql.
  Ejecutar después de DDL_techgamer.sql.
  Los datos de prueba se deshacen al final con ROLLBACK.
*/
USE techgamer;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- 1. CARGA DE DATOS DE PRUEBA CONTROLADOS
INSERT INTO CATEGORIA (nombre, descripcion)
VALUES ('QA Categoria Pruebas', 'Categoria temporal para casos de prueba');
DECLARE @id_categoria INT = SCOPE_IDENTITY();

INSERT INTO PROVEEDOR (cuil, razon_social, telefono, email)
VALUES ('30-98765432-1', 'QA Proveedor Pruebas S.A.', '3794000001', 'qa.proveedor@example.com');
DECLARE @id_proveedor INT = SCOPE_IDENTITY();

INSERT INTO CLIENTE (nombre, apellido, dni, email, telefono)
VALUES ('QA', 'Cliente Pruebas', '98765432', 'qa.cliente@example.com', '3794000002');
DECLARE @id_cliente INT = SCOPE_IDENTITY();

INSERT INTO EMPLEADO (nombre, apellido, legajo, telefono)
VALUES ('QA', 'Empleado Pruebas', 'QA-TEST-01', '3794000003');
DECLARE @id_empleado INT = SCOPE_IDENTITY();

INSERT INTO FORMA_PAGO (descripcion) VALUES ('QA Efectivo Pruebas');
DECLARE @id_pago_efectivo INT = SCOPE_IDENTITY();

INSERT INTO FORMA_PAGO (descripcion) VALUES ('QA Transferencia Pruebas');
DECLARE @id_pago_transferencia INT = SCOPE_IDENTITY();

-- Producto 1: stock bajo y vendido.
INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor)
VALUES ('QA Mouse Stock Bajo', 10000.00, 4, @id_categoria, @id_proveedor);
DECLARE @id_producto_bajo INT = SCOPE_IDENTITY();

-- Producto 2: stock cero y sin ventas.
INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor)
VALUES ('QA Teclado Sin Ventas', 20000.00, 0, @id_categoria, @id_proveedor);
DECLARE @id_producto_sin_ventas INT = SCOPE_IDENTITY();

-- Producto 3: stock suficiente y vendido.
INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor)
VALUES ('QA Auriculares Stock Normal', 15000.00, 20, @id_categoria, @id_proveedor);
DECLARE @id_producto_normal INT = SCOPE_IDENTITY();

-- Dos ventas de prueba, cada una con una forma de pago diferente.
INSERT INTO VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
VALUES ('2026-10-01T10:00:00', 10000.00, @id_cliente, @id_empleado, @id_pago_efectivo);
DECLARE @id_venta_efectivo INT = SCOPE_IDENTITY();

INSERT INTO VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
VALUES ('2026-10-02T11:00:00', 30000.00, @id_cliente, @id_empleado, @id_pago_transferencia);
DECLARE @id_venta_transferencia INT = SCOPE_IDENTITY();

INSERT INTO DETALLE_VENTA (cantidad, precio_unitario, id_venta, id_producto)
VALUES
    (1, 10000.00, @id_venta_efectivo, @id_producto_bajo),
    (2, 15000.00, @id_venta_transferencia, @id_producto_normal);


-- 2. EJECUCIÓN Y VALIDACIÓN DE RESULTADOS ESPERADOS

/* CASO DE PRUEBA 1: Productos con stock bajo.
   Esperado: "QA Mouse Stock Bajo", stock = 4.
   Se usa el rango 0 < stock < 5 para comprobar el límite.
*/
SELECT
    id_producto,
    nombre AS producto,
    stock
FROM PRODUCTO
WHERE id_categoria = @id_categoria
  AND stock > 0
  AND stock < 5
ORDER BY stock ASC;


/* CASO DE PRUEBA 2: Total de ventas agrupado por forma de pago.
   Esperado:
   - QA Efectivo Pruebas:      1 venta, total = 10000.00
   - QA Transferencia Pruebas: 1 venta, total = 30000.00
*/
SELECT
    FP.descripcion AS forma_pago,
    COUNT(V.id_venta) AS cantidad_ventas,
    SUM(V.total) AS total_vendido
FROM VENTA AS V
INNER JOIN FORMA_PAGO AS FP
    ON V.id_forma_pago = FP.id_forma_pago
WHERE V.id_venta IN (@id_venta_efectivo, @id_venta_transferencia)
GROUP BY FP.descripcion
ORDER BY total_vendido DESC;


/* CASO DE PRUEBA 3: Productos de la categoría que no registran ventas.
   Esperado: solo "QA Teclado Sin Ventas".
   LEFT JOIN conserva productos sin coincidencias en DETALLE_VENTA.
*/
SELECT
    P.id_producto,
    P.nombre AS producto,
    P.stock
FROM PRODUCTO AS P
LEFT JOIN DETALLE_VENTA AS DV
    ON P.id_producto = DV.id_producto
WHERE P.id_categoria = @id_categoria
  AND DV.id_detalle IS NULL
ORDER BY P.nombre;


-- Deshacer los registros de prueba al finalizar.
ROLLBACK TRANSACTION;
GO
