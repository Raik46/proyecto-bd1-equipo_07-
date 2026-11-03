# Procedimientos y funciones almacenadas

Base de datos: `techgamer` (SQL Server). Script de prueba: `EtapaV_Demo_Procedimientos.sql`.

## Qué se hizo

Se crearon dos objetos para no repetir lógica de negocio en cada consulta y para que las ventas se registren siempre de la misma forma:

| Objeto | Tipo | Para qué sirve |
|---|---|---|
| `dbo.fn_CalcularDescuentoCliente` | Función | Devuelve el descuento que le corresponde a un cliente según lo que compró hasta ahora |
| `dbo.sp_RegistrarVentaCompleta` | Procedimiento | Registra una venta completa: cabecera, detalle y baja de stock |

## fn_CalcularDescuentoCliente

Recibe el `id_cliente`, suma el `total` de todas sus ventas y devuelve un porcentaje:

| Total acumulado | Descuento |
|---|---|
| Más de $500.000 | 10% |
| Más de $200.000 | 5% |
| El resto | 0% |

Con los datos cargados, el cliente 5 queda con 10%, los clientes 3, 4 y 7 con 5% y el resto con 0%.

La función hace un `SUM(total)` filtrando por cliente, por eso se le agregó el índice `IX_VENTA_id_cliente` (ver `indices-optimizacion.md`).

## sp_RegistrarVentaCompleta

Parámetros: `@id_cliente`, `@id_empleado`, `@id_forma_pago`, `@id_producto`, `@cantidad`.

Lo que hace, en orden:

1. Valida que la cantidad sea mayor a 0.
2. Valida que el producto exista.
3. Valida que haya stock suficiente.
4. Calcula el descuento del cliente con la función.
5. Crea la venta, crea el detalle y descuenta el stock.

Ejemplo: el cliente 5 (10% de descuento) compra 2 unidades del producto 2 (Mouse Logitech G203, $28.000 c/u). El total queda en 28.000 × 2 × 0,90 = **$50.400** y el stock baja en 2.

## Validaciones

| Caso | Mensaje |
|---|---|
| Cantidad igual a 0 | `Error: La cantidad vendida debe ser mayor a 0.` |
| Producto que no existe (999) | `Error: El producto especificado no existe.` |
| Pedir más que el stock (6 sillas gamer, hay 5) | `Error: Stock insuficiente para realizar la venta.` |

Después de las tres pruebas fallidas se comprobó que el stock del producto 10 sigue en 5 y que la cantidad de ventas no cambió, o sea que un rechazo no deja nada a medias.

## Cómo probarlo

Ejecutar `EtapaV_Demo_Procedimientos.sql`. La venta exitosa está dentro de una transacción con `ROLLBACK`, así que se puede repetir sin alterar los datos.
