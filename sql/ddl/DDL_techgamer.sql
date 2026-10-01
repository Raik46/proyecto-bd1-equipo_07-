-- =====================================================
-- TechGamer - Etapa III: Implementación Física
-- =====================================================

USE master;
GO

IF DB_ID('techgamer') IS NOT NULL
BEGIN
  ALTER DATABASE techgamer SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE techgamer;
END
GO

CREATE DATABASE techgamer;
GO

USE techgamer;
GO

-- -----------------------------------------------------
-- CATEGORIA
-- -----------------------------------------------------
CREATE TABLE CATEGORIA
(
  id_categoria INT          NOT NULL IDENTITY (1,1),
  nombre       VARCHAR(50)  NOT NULL,
  descripcion  VARCHAR(150) NOT NULL
);

ALTER TABLE CATEGORIA
  ADD CONSTRAINT PK_CATEGORIA PRIMARY KEY (id_categoria),
      CONSTRAINT UQ_CATEGORIA_NOMBRE UNIQUE (nombre);

-- -----------------------------------------------------
-- PROVEEDOR
-- -----------------------------------------------------
CREATE TABLE PROVEEDOR
(
  id_proveedor INT          NOT NULL IDENTITY (1,1),
  cuil         VARCHAR(13)  NOT NULL,
  razon_social VARCHAR(100) NOT NULL,
  telefono     VARCHAR(20)  NOT NULL,
  email        VARCHAR(100) NOT NULL
);

ALTER TABLE PROVEEDOR
  ADD CONSTRAINT PK_PROVEEDOR PRIMARY KEY (id_proveedor),
      CONSTRAINT UQ_PROVEEDOR_CUIL UNIQUE (cuil),
      CONSTRAINT CK_PROVEEDOR_CUIL CHECK (cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
      CONSTRAINT CK_PROVEEDOR_EMAIL CHECK (email LIKE '%_@_%.__%');

-- -----------------------------------------------------
-- PRODUCTO
-- -----------------------------------------------------
CREATE TABLE PRODUCTO
(
  id_producto  INT           NOT NULL IDENTITY (1,1),
  nombre       VARCHAR(100)  NOT NULL,
  precio       DECIMAL(10,2) NOT NULL,
  stock        INT           NOT NULL,
  id_categoria INT           NOT NULL,
  id_proveedor INT           NOT NULL
);

ALTER TABLE PRODUCTO
  ADD CONSTRAINT PK_PRODUCTO PRIMARY KEY (id_producto),
      CONSTRAINT DF_PRODUCTO_STOCK DEFAULT 0 FOR stock,
      CONSTRAINT CK_PRODUCTO_PRECIO CHECK (precio > 0),
      CONSTRAINT CK_PRODUCTO_STOCK CHECK (stock >= 0),
      CONSTRAINT FK_PRODUCTO_CATEGORIA FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIA(id_categoria)
        ON DELETE NO ACTION ON UPDATE CASCADE,
      CONSTRAINT FK_PRODUCTO_PROVEEDOR FOREIGN KEY (id_proveedor)
        REFERENCES PROVEEDOR(id_proveedor)
        ON DELETE NO ACTION ON UPDATE CASCADE;

-- -----------------------------------------------------
-- CLIENTE
-- -----------------------------------------------------
CREATE TABLE CLIENTE
(
  id_cliente INT          NOT NULL IDENTITY (1,1),
  nombre     VARCHAR(50)  NOT NULL,
  apellido   VARCHAR(50)  NOT NULL,
  dni        VARCHAR(8)   NOT NULL,
  email      VARCHAR(100) NOT NULL,
  telefono   VARCHAR(20)  NOT NULL
);

ALTER TABLE CLIENTE
  ADD CONSTRAINT PK_CLIENTE PRIMARY KEY (id_cliente),
      CONSTRAINT UQ_CLIENTE_DNI UNIQUE (dni),
      CONSTRAINT CK_CLIENTE_DNI CHECK (dni LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
      CONSTRAINT CK_CLIENTE_EMAIL CHECK (email LIKE '%_@_%.__%');

-- -----------------------------------------------------
-- EMPLEADO
-- -----------------------------------------------------
CREATE TABLE EMPLEADO
(
  id_empleado INT NOT NULL IDENTITY (1,1),
  nombre      VARCHAR(50) NOT NULL,
  apellido    VARCHAR(50) NOT NULL,
  legajo      VARCHAR(10) NOT NULL,
  telefono    VARCHAR(20) NOT NULL
);

ALTER TABLE EMPLEADO
  ADD CONSTRAINT PK_EMPLEADO PRIMARY KEY (id_empleado),
      CONSTRAINT UQ_EMPLEADO_LEGAJO UNIQUE (legajo);

-- -----------------------------------------------------
-- FORMA_PAGO
-- -----------------------------------------------------
CREATE TABLE FORMA_PAGO
(
  id_forma_pago INT NOT NULL IDENTITY (1,1),
  descripcion   VARCHAR(50) NOT NULL
);

ALTER TABLE FORMA_PAGO
  ADD CONSTRAINT PK_FORMA_PAGO PRIMARY KEY (id_forma_pago),
      CONSTRAINT UQ_FORMA_PAGO_DESCRIPCION UNIQUE (descripcion);

-- -----------------------------------------------------
-- VENTA
-- -----------------------------------------------------
CREATE TABLE VENTA
(
  id_venta      INT           NOT NULL IDENTITY (1,1),
  fecha         DATETIME      NOT NULL,
  total         DECIMAL(12,2) NOT NULL,
  id_cliente    INT           NOT NULL,
  id_empleado   INT           NOT NULL,
  id_forma_pago INT           NOT NULL
);

ALTER TABLE VENTA
  ADD CONSTRAINT PK_VENTA       PRIMARY KEY (id_venta),
      CONSTRAINT DF_VENTA_FECHA DEFAULT GETDATE() FOR fecha,
      CONSTRAINT CK_VENTA_TOTAL CHECK (total >= 0),
      CONSTRAINT FK_VENTA_CLIENTE FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
        ON DELETE NO ACTION ON UPDATE CASCADE,
      CONSTRAINT FK_VENTA_EMPLEADO FOREIGN KEY (id_empleado)
        REFERENCES EMPLEADO(id_empleado)
        ON DELETE NO ACTION ON UPDATE CASCADE,
      CONSTRAINT FK_VENTA_FORMA_PAGO FOREIGN KEY (id_forma_pago)
        REFERENCES FORMA_PAGO(id_forma_pago)
        ON DELETE NO ACTION ON UPDATE CASCADE;

-- -----------------------------------------------------
-- DETALLE_VENTA
-- -----------------------------------------------------
CREATE TABLE DETALLE_VENTA
(
  id_detalle      INT           NOT NULL IDENTITY (1,1),
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  id_venta        INT           NOT NULL,
  id_producto     INT           NOT NULL
);

ALTER TABLE DETALLE_VENTA
  ADD CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY (id_detalle),
      CONSTRAINT UQ_DETALLE_VENTA_PRODUCTO UNIQUE (id_venta, id_producto),
      CONSTRAINT CK_DETALLE_CANTIDAD CHECK (cantidad > 0),
      CONSTRAINT CK_DETALLE_PRECIO   CHECK (precio_unitario > 0),
      CONSTRAINT FK_DETALLE_VENTA FOREIGN KEY (id_venta)
        REFERENCES VENTA(id_venta)
        ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT FK_DETALLE_PRODUCTO FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON DELETE NO ACTION ON UPDATE CASCADE;
GO
