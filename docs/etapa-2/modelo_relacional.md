# Modelo Relacional - Base de Datos: `techgamer`

A continuación se detalla el esquema relacional derivado del script SQL de creación de la base de datos `techgamer`, incluyendo sus tablas, atributos, tipos de datos y restricciones.

![Diagrama Entidad Relación (DER)](TechGamer(DER).jpg)

---

## 1. Entidades y Atributos

### Tabla: `CATEGORIA`
Almacena las clasificaciones de los productos.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_categoria** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| nombre | VARCHAR(50) | **UQ**, NOT NULL |
| descripcion | VARCHAR(150) | NOT NULL |

### Tabla: `PROVEEDOR`
Registra los datos de los proveedores de mercadería.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_proveedor** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| cuil | VARCHAR(13) | **UQ**, NOT NULL, **CK** (Formato XX-XXXXXXXX-X) |
| razon_social | VARCHAR(100) | NOT NULL |
| telefono | VARCHAR(20) | NOT NULL |
| email | VARCHAR(100) | NOT NULL, **CK** (Formato correo) |

### Tabla: `PRODUCTO`
Catálogo de productos disponibles para la venta.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_producto** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| nombre | VARCHAR(100) | NOT NULL |
| precio | DECIMAL(10,2) | NOT NULL, **CK** (> 0) |
| stock | INT | NOT NULL, **DF** (0), **CK** (>= 0) |
| id_categoria | INT | **FK** -> `CATEGORIA(id_categoria)`, NOT NULL |
| id_proveedor | INT | **FK** -> `PROVEEDOR(id_proveedor)`, NOT NULL |

### Tabla: `CLIENTE`
Información de los clientes compradores.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_cliente** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| nombre | VARCHAR(50) | NOT NULL |
| apellido | VARCHAR(50) | NOT NULL |
| dni | VARCHAR(8) | **UQ**, NOT NULL, **CK** (8 dígitos) |
| email | VARCHAR(100) | NOT NULL, **CK** (Formato correo) |
| telefono | VARCHAR(20) | NOT NULL |

### Tabla: `EMPLEADO`
Personal de la tienda que realiza las ventas.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_empleado** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| nombre | VARCHAR(50) | NOT NULL |
| apellido | VARCHAR(50) | NOT NULL |
| legajo | VARCHAR(10) | **UQ**, NOT NULL |
| telefono | VARCHAR(20) | NOT NULL |

### Tabla: `FORMA_PAGO`
Catálogo de los métodos de pago aceptados.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_forma_pago** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| descripcion | VARCHAR(50) | **UQ**, NOT NULL |

### Tabla: `VENTA`
Cabecera de las transacciones de venta.
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_venta** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| fecha | DATETIME | NOT NULL, **DF** (GETDATE()) |
| total | DECIMAL(12,2) | NOT NULL, **CK** (>= 0) |
| id_cliente | INT | **FK** -> `CLIENTE(id_cliente)`, NOT NULL |
| id_empleado | INT | **FK** -> `EMPLEADO(id_empleado)`, NOT NULL |
| id_forma_pago | INT | **FK** -> `FORMA_PAGO(id_forma_pago)`, NOT NULL |

### Tabla: `DETALLE_VENTA`
Líneas de detalle de cada venta (relación de muchos a muchos entre VENTA y PRODUCTO).
| Columna | Tipo de Dato | Restricciones / Notas |
| :--- | :--- | :--- |
| **id_detalle** | INT | **PK**, IDENTITY(1,1), NOT NULL |
| cantidad | INT | NOT NULL, **CK** (> 0) |
| precio_unitario | DECIMAL(10,2) | NOT NULL, **CK** (> 0) |
| id_venta | INT | **FK** -> `VENTA(id_venta)`, NOT NULL |
| id_producto | INT | **FK** -> `PRODUCTO(id_producto)`, NOT NULL |

*Nota: Existe una restricción **UQ** (Unique) combinada entre `id_venta` e `id_producto` para evitar que un mismo producto se registre en dos líneas separadas dentro del mismo comprobante.*

---

## 2. Relaciones (Cardinalidad)

*   **CATEGORIA (1) -> (N) PRODUCTO:** Una categoría puede tener muchos productos, pero un producto pertenece a una sola categoría.
*   **PROVEEDOR (1) -> (N) PRODUCTO:** Un proveedor suministra múltiples productos, cada producto proviene de un solo proveedor.
*   **CLIENTE (1) -> (N) VENTA:** Un cliente puede realizar varias ventas/compras.
*   **EMPLEADO (1) -> (N) VENTA:** Un empleado puede registrar múltiples ventas.
*   **FORMA_PAGO (1) -> (N) VENTA:** Una forma de pago puede utilizarse en muchas ventas.
*   **VENTA (1) -> (N) DETALLE_VENTA:** Una venta puede tener varios detalles (líneas de productos).
*   **PRODUCTO (1) -> (N) DETALLE_VENTA:** Un producto puede aparecer en los detalles de múltiples ventas.

---
**Leyenda:**
* **PK:** Primary Key (Clave Primaria)
* **FK:** Foreign Key (Clave Foránea)
* **UQ:** Unique (Clave Única)
* **CK:** Check (Restricción de validación)
* **DF:** Default (Valor por defecto)
