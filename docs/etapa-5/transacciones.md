# Transacciones

Base de datos: `techgamer` (SQL Server).

## Por qué hacen falta

Registrar una venta toca tres cosas a la vez: la tabla `VENTA`, la tabla `DETALLE_VENTA` y el stock en `PRODUCTO`. Si algo falla a la mitad (por ejemplo, se crea la venta pero no se puede bajar el stock) la base quedaría inconsistente. Una transacción garantiza que o se hace todo o no se hace nada.

## Dónde se usa

- **`sp_RegistrarVentaCompleta`**: la venta, el detalle y el descuento de stock se hacen como una sola unidad de trabajo.
- **Scripts de demo**: las pruebas que no deben dejar datos se envuelven en `BEGIN TRANSACTION` / `ROLLBACK TRANSACTION`.

## Ejemplo de la demo

```sql
BEGIN TRANSACTION;

    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 5, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 2, @cantidad = 2;

    -- acá se consulta VENTA, DETALLE_VENTA y PRODUCTO:
    -- se ve la venta nueva y el stock bajado en 2

ROLLBACK TRANSACTION;
-- después del rollback todo vuelve a como estaba
```

Para conservar la venta se cambia `ROLLBACK` por `COMMIT`.

## Qué se comprobó

| Prueba | Resultado |
|---|---|
| Venta exitosa dentro de la transacción | Se crea la venta, el detalle y el stock baja en 2 |
| `ROLLBACK` al final | Los datos quedan como antes de empezar |
| Venta rechazada (cantidad 0, producto inexistente, stock insuficiente) | No se crea ninguna venta y el stock no cambia |

## Reglas de integridad que ayudan

- `DETALLE_VENTA` tiene `ON DELETE CASCADE` con `VENTA`: si se borra una venta se borran sus detalles.
- `CK_PRODUCTO_STOCK` impide que el stock quede negativo, aunque falle una validación.
- `CK_DETALLE_CANTIDAD` y `CK_DETALLE_PRECIO` impiden cantidades y precios menores o iguales a 0.
