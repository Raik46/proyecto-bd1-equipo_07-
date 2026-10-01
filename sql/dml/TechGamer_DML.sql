-- =====================================================
-- TechGamer - Etapa III: Implementación Física
-- Script DML (SQL Server - T-SQL). Ejecutar DESPUÉS del DDL.
-- Los id_* son IDENTITY: se generan solos (1, 2, 3...) en el
-- orden en que se insertan las filas. Datos ficticios de prueba.
-- =====================================================

USE techgamer;
GO

-- -----------------------------------------------------
-- CATEGORIA (10)
-- -----------------------------------------------------
INSERT INTO CATEGORIA (nombre, descripcion) VALUES
('Periféricos',     'Teclados, mouses y accesorios de escritorio'),
('Componentes PC',  'Procesadores, motherboards y refrigeración'),
('Monitores',       'Monitores gamer de alta tasa de refresco'),
('Almacenamiento',  'Discos sólidos, rígidos y unidades externas'),
('Placas de video', 'Tarjetas gráficas dedicadas'),
('Memorias RAM',    'Módulos de memoria DDR4 y DDR5'),
('Gabinetes',       'Gabinetes y cajas para armado de PC'),
('Fuentes',         'Fuentes de alimentación certificadas'),
('Audio',           'Auriculares, parlantes y micrófonos'),
('Sillas gamer',    'Sillas ergonómicas para largas sesiones');

-- -----------------------------------------------------
-- PROVEEDOR (10)
-- -----------------------------------------------------
INSERT INTO PROVEEDOR (cuil, razon_social, telefono, email) VALUES
('30-71234567-1', 'Redragon Argentina S.A.',        '+54 11 4555-0101', 'ventas@redragon-ar.com'),
('30-71234568-9', 'Logitech Distribuciones S.R.L.', '+54 11 4555-0102', 'contacto@logidist.com.ar'),
('30-71234569-7', 'HyperX Cono Sur S.A.',           '+54 11 4555-0103', 'pedidos@hyperxcs.com'),
('30-71234570-0', 'Samsung Mayorista S.A.',         '+54 11 4555-0104', 'mayorista@samsungmay.com'),
('30-71234571-9', 'Kingston Tech Argentina S.R.L.', '+54 11 4555-0105', 'ventas@kingstontech.com.ar'),
('30-71234572-7', 'NVIDIA Partners Argentina S.A.', '+54 11 4555-0106', 'partners@nvpartners.com.ar'),
('30-71234573-5', 'Corsair Latam S.A.',              '+54 11 4555-0107', 'latam@corsairlatam.com'),
('30-71234574-3', 'Cooler Master Argentina S.R.L.', '+54 11 4555-0108', 'ventas@coolermaster-ar.com'),
('30-71234575-1', 'Compumundo Mayorista S.A.',      '+54 379 442-0109', 'mayorista@compumundo.com.ar'),
('30-71234576-0', 'Cougar Gaming Argentina S.A.',   '+54 11 4555-0110', 'info@cougar-ar.com');

-- -----------------------------------------------------
-- PRODUCTO (10)   (nombre, precio, stock, id_categoria, id_proveedor)
-- -----------------------------------------------------
INSERT INTO PRODUCTO (nombre, precio, stock, id_categoria, id_proveedor) VALUES
('Teclado Redragon Kumara K552',      45000.00, 25, 1,  1),
('Mouse Logitech G203',               28000.00, 40, 1,  2),
('Auriculares HyperX Cloud Stinger',  52000.00, 18, 9,  3),
('Monitor Samsung 24" 144Hz',        210000.00, 12, 3,  4),
('SSD Kingston NV2 1TB',              75000.00, 30, 4,  5),
('Placa de video RTX 4060 8GB',      620000.00,  6, 5,  6),
('Memoria RAM Corsair 16GB DDR4',     58000.00, 35, 6,  7),
('Gabinete Cooler Master MB520',      95000.00, 10, 7,  8),
('Fuente Corsair CV650 650W',         88000.00, 14, 8,  9),
('Silla gamer Cougar Armor',         260000.00,  5, 10, 10);

-- -----------------------------------------------------
-- CLIENTE (10)
-- -----------------------------------------------------
INSERT INTO CLIENTE (nombre, apellido, dni, email, telefono) VALUES
('Lucas',     'Fernández', '38123456', 'lucas.fernandez@mail.com',  '+54 379 415-1001'),
('Martina',   'Gómez',     '40234567', 'martina.gomez@mail.com',    '+54 379 415-1002'),
('Joaquín',   'Benítez',   '36345678', 'joaquin.benitez@mail.com',  '+54 379 415-1003'),
('Camila',    'Romero',    '41456789', 'camila.romero@mail.com',    '+54 379 415-1004'),
('Mateo',     'Acosta',    '39567890', 'mateo.acosta@mail.com',     '+54 379 415-1005'),
('Sofía',     'Villalba',  '42678901', 'sofia.villalba@mail.com',   '+54 379 415-1006'),
('Tomás',     'Giménez',   '37789012', 'tomas.gimenez@mail.com',    '+54 379 415-1007'),
('Valentina', 'Ojeda',     '43890123', 'valentina.ojeda@mail.com',  '+54 379 415-1008'),
('Nicolás',   'Ledesma',   '35901234', 'nicolas.ledesma@mail.com',  '+54 379 415-1009'),
('Julieta',   'Sosa',      '44012345', 'julieta.sosa@mail.com',     '+54 379 415-1010');

-- -----------------------------------------------------
-- EMPLEADO (8)
-- -----------------------------------------------------
INSERT INTO EMPLEADO (nombre, apellido, legajo, telefono) VALUES
('Carlos',    'Medina',  'LEG-001', '+54 379 420-2001'),
('Laura',     'Duarte',  'LEG-002', '+54 379 420-2002'),
('Federico',  'Ríos',    'LEG-003', '+54 379 420-2003'),
('Paula',     'Cardozo', 'LEG-004', '+54 379 420-2004'),
('Diego',     'Vera',    'LEG-005', '+54 379 420-2005'),
('Romina',    'Aguirre', 'LEG-006', '+54 379 420-2006'),
('Gastón',    'Monzón',  'LEG-007', '+54 379 420-2007'),
('Florencia', 'Báez',    'LEG-008', '+54 379 420-2008');

-- -----------------------------------------------------
-- FORMA_PAGO (8)
-- -----------------------------------------------------
INSERT INTO FORMA_PAGO (descripcion) VALUES
('Efectivo'),
('Tarjeta de débito'),
('Tarjeta de crédito'),
('Transferencia bancaria'),
('Mercado Pago'),
('Código QR'),
('Cheque'),
('Cuenta corriente');

-- -----------------------------------------------------
-- VENTA (10)  (fecha, total, id_cliente, id_empleado, id_forma_pago)
-- Totales = suma de sus renglones en DETALLE_VENTA.
-- Fechas en formato ISO con T (no depende del idioma del servidor).
-- -----------------------------------------------------
INSERT INTO VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago) VALUES
('2026-09-01T10:15:00',  73000.00, 1,  1, 1),
('2026-09-03T16:40:00', 104000.00, 2,  2, 2),
('2026-09-05T11:05:00', 210000.00, 3,  1, 3),
('2026-09-08T18:20:00', 266000.00, 4,  3, 1),
('2026-09-10T09:50:00', 620000.00, 5,  2, 4),
('2026-09-12T17:30:00', 183000.00, 6,  4, 2),
('2026-09-15T12:10:00', 260000.00, 7,  3, 5),
('2026-09-18T15:45:00', 129000.00, 8,  1, 3),
('2026-09-22T10:25:00', 133000.00, 9,  5, 1),
('2026-09-26T19:00:00', 142000.00, 10, 4, 2);

-- -----------------------------------------------------
-- DETALLE_VENTA (16)  (cantidad, precio_unitario, id_venta, id_producto)
-- -----------------------------------------------------
INSERT INTO DETALLE_VENTA (cantidad, precio_unitario, id_venta, id_producto) VALUES
(1,  45000.00, 1,  1),
(1,  28000.00, 1,  2),
(2,  52000.00, 2,  3),
(1, 210000.00, 3,  4),
(2,  75000.00, 4,  5),
(2,  58000.00, 4,  7),
(1, 620000.00, 5,  6),
(1,  95000.00, 6,  8),
(1,  88000.00, 6,  9),
(1, 260000.00, 7,  10),
(3,  28000.00, 8,  2),
(1,  45000.00, 8,  1),
(1,  58000.00, 9,  7),
(1,  75000.00, 9,  5),
(1,  52000.00, 10, 3),
(2,  45000.00, 10, 1);
GO
