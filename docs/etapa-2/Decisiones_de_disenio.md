# Decisiones de diseño

## Separacion de las entidades

Se decidio mantener separadas las entidades principales del sistema, como **CATEGORIA**, **PROVEEDOR**, **PRODUCTO**, **CLIENTE**, **EMPLEADO**, **FORMA_PAGO** y **VENTA**, ya que cada una representa un concepto diferente dentro del dominio y posee sus propios datos,

## Relacion entre Producto y Categoria

Se decidio que cada producto pertenece a una categoria y que una categoria puede contener varios productos, por eso `id_categoria` se encuentra en **PRODUCTO** como clave foranea,

## Relacion entre Producto y Proveedor

Se mantuvo la informacion del proveedor en una tabla independiente y **PRODUCTO** solamente guarda `id_proveedor`, evitando repetir los datos del proveedor en cada producto,

## Relacion entre Venta y Cliente

Se decidio que una venta pertenece a un cliente y que un cliente puede realizar varias ventas, por eso `id_cliente` se encuentra en **VENTA** como clave foranea,

## Relacion entre Venta y Empleado

Se decidio que el empleado no debe guardar una venta directamente, ya que un empleado puede registrar varias ventas, por eso `id_empleado` se encuentra en **VENTA**,

## Relacion entre Venta y Producto

Una venta puede contener varios productos y un producto puede aparecer en distintas ventas, por lo que se utilizo **DETALLE_VENTA** para representar esta relacion,

En **DETALLE_VENTA** se almacenan datos propios de esa relacion, como `cantidad` y `precio_unitario`, mientras que la informacion general del producto permanece en **PRODUCTO**,

## Identificacion de Detalle_Venta

Se decidio utilizar `id_detalle` como clave primaria de **DETALLE_VENTA**, manteniendo `id_venta` e `id_producto` como claves foraneas, tambien se establecio una restriccion `UNIQUE` sobre ambos campos para evitar repetir el mismo producto dentro de una venta,

## Tipos de datos

Se utilizaron tipos de datos adecuados para cada atributo, por ejemplo, `DECIMAL` para precios y totales, `VARCHAR` para datos como nombres, telefonos, emails y CUIL, e `INT` para identificadores y cantidades,

## Restricciones de integridad

Se utilizaron claves primarias para identificar los registros, claves foraneas para mantener las relaciones entre las tablas, `UNIQUE` para evitar valores repetidos y `CHECK` para controlar valores que deben cumplir determinadas condiciones,

## Normalizacion

Las decisiones tomadas durante el diseño buscan mantener el modelo normalizado, evitando datos repetidos y separando la informacion que pertenece a cada entidad, el modelo fue revisado en 1FN, 2FN y 3FN, realizando los cambios necesarios para cumplir con cada etapa,
