SUM(v.total) AS total_gastado
FROM CLIENTE AS c
INNER JOIN VENTA AS v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING SUM(v.total) > (
    SELECT AVG(CAST(total AS DECIMAL(18, 2)))
    FROM VENTA
)
ORDER BY total_gastado DESC;
GO

/*====================================================================
  CASO DE USO 6 - VENTAS AGRUPADAS POR FORMA DE PAGO
  Objetivo: mostrar cantidad de ventas y monto total registrado en VENTA
  para cada forma de pago. Se excluyen formas de pago que no tengan ventas.
====================================================================*/
SELECT
    fp.id_forma_pago,
    fp.descripcion AS forma_pago,
    COUNT(v.id_venta) AS cantidad_ventas,
    SUM(v.total) AS total_vendido
FROM FORMA_PAGO AS fp
INNER JOIN VENTA AS v ON v.id_forma_pago = fp.id_forma_pago
GROUP BY fp.id_forma_pago, fp.descripcion
ORDER BY total_vendido DESC;
GO

/*====================================================================
  CASO DE USO 7 - PRODUCTOS CON STOCK BAJO
  Objetivo: identificar productos con stock mayor que cero e inferior a 5.
====================================================================*/
SELECT
    p.id_producto,
    p.nombre AS producto,
    p.stock,
    c.nombre AS categoria
FROM PRODUCTO AS p
INNER JOIN CATEGORIA AS c ON c.id_categoria = p.id_categoria
WHERE p.stock > 0
  AND p.stock < 5
ORDER BY p.stock ASC, p.nombre;
GO

/*====================================================================
  CASO DE USO 8 - PRODUCTOS SIN VENTAS
  Objetivo: encontrar productos que no aparecen en DETALLE_VENTA.
  LEFT JOIN conserva los productos aunque no tengan detalles asociados.
====================================================================*/
SELECT
    p.id_producto,
    p.nombre AS producto,
    p.stock,
    c.nombre AS categoria
FROM PRODUCTO AS p
INNER JOIN CATEGORIA AS c ON c.id_categoria = p.id_categoria
LEFT JOIN DETALLE_VENTA AS dv ON dv.id_producto = p.id_producto
WHERE dv.id_detalle IS NULL
ORDER BY p.nombre;
GO

/*====================================================================
  PRUEBAS ADICIONALES CONTROLADAS

  Se crean registros temporales para validar:
    1. Productos con stock bajo.
    2. Ventas agrupadas por forma de pago.
    3. Productos de una categoría sin ventas.

  Se respetan las columnas NOT NULL, las restricciones de formato del
  DDL y las relaciones entre tablas. El ROLLBACK final deshace todo.
====================================================================*/
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO CATEGORIA (nombre, descripcion)
    VALUES ('QA Categoria Pruebas', 'Categoria temporal para casos de prueba');
    DECLARE @id_categoria_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO PROVEEDOR (cuil, razon_social, telefono, email)
    VALUES ('30-98765432-1', 'QA Proveedor Pruebas S.A.', '3794000001', 'qa.proveedor@example.com');
    DECLARE @id_proveedor_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO CLIENTE (nombre, apellido, dni, email, telefono)
    VALUES ('QA', 'Cliente Pruebas', '98765432', 'qa.cliente@example.com', '3794000002');
    DECLARE @id_cliente_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO EMPLEADO (nombre, apellido, legajo, telefono)
    VALUES ('QA', 'Empleado Pruebas', 'QA-TEST-01', '3794000003');
    DECLARE @id_empleado_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO FORMA_PAGO (descripcion) VALUES ('QA Efectivo Pruebas');
    DECLARE @id_pago_efectivo_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO FORMA_PAGO (descripcion) VALUES ('QA Transferencia Pruebas');
    DECLARE @id_pago_transferencia_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor)
    VALUES ('QA Mouse Stock Bajo', 10000.00, 4, @id_categoria_qa, @id_proveedor_qa);
    DECLARE @id_producto_bajo_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor)
    VALUES ('QA Teclado Sin Ventas', 20000.00, 0, @id_categoria_qa, @id_proveedor_qa);
    DECLARE @id_producto_sin_ventas_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor)
    VALUES ('QA Auriculares Stock Normal', 15000.00, 20, @id_categoria_qa, @id_proveedor_qa);
    DECLARE @id_producto_normal_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES ('20261001T10:00:00', 10000.00, @id_cliente_qa, @id_empleado_qa, @id_pago_efectivo_qa);
    DECLARE @id_venta_efectivo_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
    VALUES ('20261002T11:00:00', 30000.00, @id_cliente_qa, @id_empleado_qa, @id_pago_transferencia_qa);
    DECLARE @id_venta_transferencia_qa INT = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO DETALLE_VENTA (cantidad, precio_unitario, id_venta, id_producto)
    VALUES
        (1, 10000.00, @id_venta_efectivo_qa, @id_producto_bajo_qa),
        (2, 15000.00, @id_venta_transferencia_qa, @id_producto_normal_qa);

    /* PRUEBA 1: esperado: QA Mouse Stock Bajo, stock = 4. */
    SELECT id_producto, nombre AS producto, stock
    FROM PRODUCTO
    WHERE id_categoria = @id_categoria_qa
      AND stock > 0
      AND stock < 5
    ORDER BY stock ASC;

    /* PRUEBA 2: efectivo = 1 venta/$10.000; transferencia = 1/$30.000. */
    SELECT
        fp.descripcion AS forma_pago,
        COUNT(v.id_venta) AS cantidad_ventas,
        SUM(v.total) AS total_vendido
    FROM VENTA AS v
    INNER JOIN FORMA_PAGO AS fp ON fp.id_forma_pago = v.id_forma_pago
    WHERE v.id_venta IN (@id_venta_efectivo_qa, @id_venta_transferencia_qa)
    GROUP BY fp.descripcion
    ORDER BY total_vendido DESC;

    /* PRUEBA 3: esperado: QA Teclado Sin Ventas. */
    SELECT p.id_producto, p.nombre AS producto, p.stock
    FROM PRODUCTO AS p
    LEFT JOIN DETALLE_VENTA AS dv ON dv.id_producto = p.id_producto
    WHERE p.id_categoria = @id_categoria_qa
      AND dv.id_detalle IS NULL
    ORDER BY p.nombre;

    ROLLBACK TRANSACTION;
    PRINT 'Pruebas finalizadas: los datos temporales fueron revertidos.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'La prueba fallo y la transaccion fue revertida.';
    THROW;
END CATCH;