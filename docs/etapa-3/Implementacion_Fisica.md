# Implementacion fisica

La implementacion fisica corresponde al paso del modelo relacional a una base de datos real, en este caso utilizando **SQL Server**,

## Creacion de la base de datos

Se crea la base de datos y luego se selecciona para comenzar a trabajar con ella,

Tambien se contempla la posibilidad de que la base de datos ya exista, permitiendo eliminarla y volver a crearla desde cero,

## Creacion de las tablas

A partir del modelo relacional se crean las siguientes tablas,

- **CATEGORIA**
- **PROVEEDOR**
- **PRODUCTO**
- **CLIENTE**
- **EMPLEADO**
- **FORMA_PAGO**
- **VENTA**
- **DETALLE_VENTA**

Cada tabla contiene los atributos definidos en el modelo relacional,

## Identificadores

Las tablas utilizan identificadores numericos para identificar sus registros,

Estos identificadores se generan automaticamente mediante `IDENTITY`, por lo que no es necesario asignarlos manualmente al insertar nuevos registros,

## Relaciones entre tablas

Las relaciones del modelo se representan mediante los atributos correspondientes en cada tabla,

**PRODUCTO** contiene las referencias a **CATEGORIA** y **PROVEEDOR**,

**VENTA** contiene las referencias a **CLIENTE**, **EMPLEADO** y **FORMA_PAGO**,

**DETALLE_VENTA** contiene las referencias a **VENTA** y **PRODUCTO**,

## Tipos de datos

Se seleccionaron los tipos de datos de acuerdo con la informacion que almacena cada atributo,

- `INT` para identificadores y cantidades,
- `VARCHAR` para nombres, apellidos, telefonos, emails, DNI, CUIL y otros datos de texto,
- `DECIMAL` para precios y totales,
- `DATETIME` para la fecha de las ventas,

## Valores iniciales

Algunos atributos tienen valores definidos automaticamente cuando no se proporciona uno,

El `stock` de un producto comienza en `0` por defecto,

La fecha de una venta utiliza `GETDATE()` para tomar automaticamente la fecha y hora actual,

## Resultado

De esta manera se obtiene la estructura fisica de la base de datos a partir del modelo relacional, con las tablas y relaciones necesarias para almacenar la informacion del sistema,
