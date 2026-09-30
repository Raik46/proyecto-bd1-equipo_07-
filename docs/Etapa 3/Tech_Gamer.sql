-- ============================================
-- CREACIÓN DE BASE DE DATOS
-- ============================================

CREATE DATABASE IF NOT EXISTS SistemaVentas;
USE SistemaVentas;


-- ============================================
-- TABLA: Categoria
-- ============================================

CREATE TABLE Categoria
(
    id_categoria INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,

    PRIMARY KEY (id_categoria),

    UNIQUE (nombre)
);


-- ============================================
-- TABLA: Proveedor
-- ============================================

CREATE TABLE Proveedor
(
    id_proveedor INT NOT NULL,
    cuil VARCHAR(11) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    razon_social VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,

    PRIMARY KEY (id_proveedor),

    UNIQUE (cuil),
    UNIQUE (email)
);


-- ============================================
-- TABLA: Producto
-- ============================================

CREATE TABLE Producto
(
    id_producto INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,

    PRIMARY KEY (id_producto),

    FOREIGN KEY (id_categoria)
        REFERENCES Categoria(id_categoria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (id_proveedor)
        REFERENCES Proveedor(id_proveedor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (precio >= 0),
    CHECK (stock >= 0)
);


-- ============================================
-- TABLA: Forma_Pago
-- ============================================

CREATE TABLE Forma_Pago
(
    id_forma_pago INT NOT NULL,
    descripcion VARCHAR(100) NOT NULL,

    PRIMARY KEY (id_forma_pago),

    UNIQUE (descripcion)
);


-- ============================================
-- TABLA: Cliente
-- ============================================

CREATE TABLE Cliente
(
    id_cliente INT NOT NULL,
    dni VARCHAR(8) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,

    PRIMARY KEY (id_cliente),

    UNIQUE (dni),
    UNIQUE (email)
);


-- ============================================
-- TABLA: Empleado
-- ============================================

CREATE TABLE Empleado
(
    id_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    legajo INT NOT NULL,

    PRIMARY KEY (id_empleado),

    UNIQUE (legajo)
);


-- ============================================
-- TABLA: Venta
-- ============================================

CREATE TABLE Venta
(
    id_venta INT NOT NULL,
    fecha DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    id_forma_pago INT NOT NULL,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,

    PRIMARY KEY (id_venta),

    FOREIGN KEY (id_forma_pago)
        REFERENCES Forma_Pago(id_forma_pago)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (id_empleado)
        REFERENCES Empleado(id_empleado)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (total >= 0)
);


-- ============================================
-- TABLA: Detalle_Venta
-- ============================================

CREATE TABLE Detalle_Venta
(
    id_producto INT NOT NULL,
    id_venta INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (id_producto, id_venta),

    FOREIGN KEY (id_producto)
        REFERENCES Producto(id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (id_venta)
        REFERENCES Venta(id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0)
);
