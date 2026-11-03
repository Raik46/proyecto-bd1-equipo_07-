# Reglas de integridad

## Integridad de entidad

La integridad de entidad se asegura mediante las **claves primarias** de cada tabla,

Cada tabla tiene una clave primaria que identifica de forma unica cada registro y no permite valores nulos,

- **CATEGORIA** → `id_categoria`
- **PROVEEDOR** → `id_proveedor`
- **PRODUCTO** → `id_producto`
- **CLIENTE** → `id_cliente`
- **EMPLEADO** → `id_empleado`
- **FORMA_PAGO** → `id_forma_pago`
- **VENTA** → `id_venta`
- **DETALLE_VENTA** → `id_detalle`

Ademas, los identificadores se generan automaticamente mediante `IDENTITY`,

## Integridad referencial

La integridad referencial se implementa mediante **claves foraneas**, asegurando que las relaciones entre las tablas sean validas,

- `PRODUCTO.id_categoria` → `CATEGORIA.id_categoria`
- `PRODUCTO.id_proveedor` → `PROVEEDOR.id_proveedor`
- `VENTA.id_cliente` → `CLIENTE.id_cliente`
- `VENTA.id_empleado` → `EMPLEADO.id_empleado`
- `VENTA.id_forma_pago` → `FORMA_PAGO.id_forma_pago`
- `DETALLE_VENTA.id_venta` → `VENTA.id_venta`
- `DETALLE_VENTA.id_producto` → `PRODUCTO.id_producto`

De esta forma no se pueden ingresar referencias a registros que no existen,

## Integridad de dominio

La integridad de dominio se controla mediante los **tipos de datos**, `NOT NULL` y restricciones `CHECK`,

Por ejemplo,

- Los identificadores y cantidades utilizan `INT`,
- Los nombres, emails, telefonos, DNI y CUIL utilizan `VARCHAR`,
- Los precios y totales utilizan `DECIMAL`,
- La fecha de la venta utiliza `DATETIME`,
- Los atributos obligatorios se definen con `NOT NULL`,

Tambien se agregaron restricciones `CHECK` para validar determinados valores,

- `PRODUCTO.precio > 0`
- `PRODUCTO.stock >= 0`
- `VENTA.total >= 0`
- `DETALLE_VENTA.cantidad > 0`
- `DETALLE_VENTA.precio_unitario > 0`

Tambien se controla el formato del CUIL, DNI y email,

## Unicidad

Se utilizaron restricciones `UNIQUE` para evitar valores duplicados que deben ser unicos dentro del sistema,

- `CATEGORIA.nombre`
- `PROVEEDOR.cuil`
- `CLIENTE.dni`
- `EMPLEADO.legajo`
- `FORMA_PAGO.descripcion`

En **DETALLE_VENTA** se utiliza `UNIQUE(id_venta, id_producto)` para evitar que un mismo producto aparezca mas de una vez dentro de una misma venta,

## Valores por defecto

Se utilizaron valores por defecto para garantizar que determinados atributos tengan un valor cuando no se indique uno,

- `PRODUCTO.stock` → `0`
- `VENTA.fecha` → `GETDATE()`

## Reglas de eliminacion y actualizacion

Las claves foraneas tambien tienen reglas para controlar que ocurre cuando se elimina o actualiza un registro relacionado,

En las relaciones principales se utiliza `ON DELETE NO ACTION`, evitando eliminar un registro que tenga otros registros relacionados,

En **DETALLE_VENTA** se utiliza `ON DELETE CASCADE`, por lo que al eliminar una venta se eliminan automaticamente sus detalles,

Para las actualizaciones de claves relacionadas se utiliza `ON UPDATE CASCADE`,
