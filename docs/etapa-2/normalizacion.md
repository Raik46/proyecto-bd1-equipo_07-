# Normalizacion TechGamer: Primera Forma Normal (1FN)

Normalización TechGamer: Primera Forma Normal (1FN)

## 1. Qué pide la 1FN

Cada campo guarda un solo valor (atómico).

Cada tabla tiene una clave primaria única y sin nulos.

No hay columnas con varios valores ni filas repetidas.

Si hay datos que se repiten en grupo, se pasan a otra tabla y se agrega la clave de la tabla original como parte de la clave de la nueva.

## 2. Problemas del DER original

Venta e id_detalle: Venta tenía un solo id_detalle, entonces una venta podía tener un solo detalle. Como una venta tiene varios productos, había que guardar varios valores en ese campo o repetir la venta por cada producto. Es el mismo caso de la tabla FACTURA del PDF.

Empleado e id_venta: Empleado tenía el id_venta, entonces cada empleado quedaba asociado a una sola venta. Para registrar más ventas había que repetir los datos del empleado.

## 3. Cambios realizados

Se quitó id_detalle de Venta.

Se agregó id_venta a Detalle_Venta, y la clave primaria pasó a ser (id_venta, id_producto).

Se quitó id_venta de Empleado.

Se agregó id_empleado a Venta.

## 4. Resultado en 1FN

Las demás tablas ya cumplían la 1FN y no se modificaron.


| Tabla | Atributos |
|---|---|

| Empleado | id_empleado (PK), nombre, apellido, telefono, legajo |

| Cliente | id_cliente (PK), dni, nombre, apellido, email, telefono |

| Forma_Pago | id_forma_pago (PK), descripcion |

| Venta | id_venta (PK), fecha, total, id_forma_pago (FK), id_cliente (FK), id_empleado (FK) |

| Detalle_Venta | id_venta (PK, FK), id_producto (PK, FK), cantidad, precio_unitario |

| Producto | id_producto (PK), nombre, precio, stock, id_categoria (FK), id_proveedor (FK) |

| Categoria | id_categoria (PK), nombre, descripcion |

| Proveedor | id_proveedor (PK), cuil, telefono, razon_social, email |



# Normalizacion TechGamer: Segunda Forma Normal (2FN)

Normalización TechGamer: Segunda Forma Normal (2FN)

## 1. Qué pide la 2FN

La tabla ya debe estar en 1FN.

Los atributos que no son clave deben depender de toda la clave primaria, no de una parte de ella.

Esta condición solo aplica a tablas con clave primaria compuesta (formada por más de un atributo).

Si un atributo depende solo de una parte de la clave, se lo separa en otra tabla, junto con esa parte de la clave.

## 2. Problemas del modelo en 1FN

Detalle_Venta y nombre_producto: en la versión en 1FN, Detalle_Venta quedó con clave compuesta (id_venta, id_producto) porque representa la relación entre Venta y Producto. En esa versión se había dejado también el campo nombre_producto dentro de Detalle_Venta, para no tener que ir a buscarlo a la tabla Producto cada vez que se mostraba el detalle de una venta. El problema es que nombre_producto depende solo de id_producto, no de la clave completa (id_venta, id_producto), por lo que es una dependencia parcial. Es el mismo caso de la tabla DETALLE_FACTURA del PDF, donde Descripción depende solo de Cod_Articulo y no de la clave completa (Cod_Factura, Cod_Articulo).

Las demás tablas (Empleado, Cliente, Forma_Pago, Venta, Producto, Categoria, Proveedor) ya tenían clave primaria simple desde la 1FN, formada por un solo atributo. Al no tener clave compuesta, no pueden tener dependencias parciales, así que ya cumplían 2FN sin necesidad de cambios.

## 3. Cambios realizados

Se quitó nombre_producto de Detalle_Venta, ya que ese dato depende solo de id_producto y ya se encuentra en la tabla Producto.

Se reemplazó la clave primaria compuesta (id_venta, id_producto) de Detalle_Venta por una clave primaria simple, id_detalle.

id_venta e id_producto se mantuvieron en Detalle_Venta, ahora como claves foráneas, pero ya no forman parte de la clave primaria.

## 4. Resultado en 2FN

Las demás tablas ya cumplían la 2FN y no se modificaron.


| Tabla | Atributos |
|---|---|

| Empleado | id_empleado (PK), nombre, apellido, telefono, legajo |

| Cliente | id_cliente (PK), dni, nombre, apellido, email, telefono |

| Forma_Pago | id_forma_pago (PK), descripcion |

| Venta | id_venta (PK), fecha, total, id_forma_pago (FK), id_cliente (FK), id_empleado (FK) |

| Detalle_Venta | id_detalle (PK), id_venta (FK), id_producto (FK), cantidad, precio_unitario |

| Producto | id_producto (PK), nombre, precio, stock, id_categoria (FK), id_proveedor (FK) |

| Categoria | id_categoria (PK), nombre, descripcion |

| Proveedor | id_proveedor (PK), cuil, telefono, razon_social, email |



# Normalizacion TechGamer: Tercera Forma Normal (3FN)

Normalización TechGamer: Tercera Forma Normal (3FN)

## 1. Qué pide la 3FN

• Que la estructura de datos se encuentre en la 3FN.

• Las columnas que no forman parte de la clave primaria deben depender sólo de la clave, nunca de otra columna no clave.

• Evitar la dependencia transitiva.

## 2. Problemas del modelo en 2FN

Al revisar el diseño obtenido tras la aplicación de la 2FN, se observa que en las tablas actuales los atributos que no son clave ya dependen de manera directa y exclusiva de su respectiva clave primaria.

No se presentan casos donde una columna no clave dependa funcionalmente de otra columna que tampoco sea clave dentro de la misma tabla, evitando así las dependencias transitivas.

## 3. Cambios realizados

No fue necesario realizar modificaciones estructurales ni extraer atributos hacia nuevas tablas, dado que la organización de los datos heredada de la etapa anterior ya satisface plenamente las reglas de la 3FN.

## 4. Resultado en 3FN

Todas las tablas del modelo cumplen con la 3FN y se mantienen con la misma estructura establecida en la 2FN.


| Tabla | Atributos |
|---|---|

| Empleado | id_empleado (PK), nombre, apellido, telefono, legajo |

| Cliente | id_cliente (PK), dni, nombre, apellido, email, telefono |

| Forma_Pago | id_forma_pago (PK), descripcion |

| Venta | id_venta (PK), fecha, total, id_forma_pago (FK), id_cliente (FK), id_empleado (FK) |

| Detalle_Venta | id_detalle (PK), id_venta (FK), id_producto (FK), cantidad, precio_unitario |

| Producto | id_producto (PK), nombre, precio, stock, id_categoria (FK), id_proveedor (FK) |

| Categoria | id_categoria (PK), nombre, descripcion |

| Proveedor | id_proveedor (PK), cuil, telefono, razon_social, email |
