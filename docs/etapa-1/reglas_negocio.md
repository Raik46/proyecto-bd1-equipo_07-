# Reglas de negocio — Etapa 1

| Código | Regla | Descripción |
|---|---|---|
| RN.01 | Control de stock | No se puede realizar una venta si la cantidad pedida de un producto es mayor al stock en el inventario. Cuando la venta se confirma, el stock del producto tiene que descontarse de la base de datos. |
| RN.02 | Registro de clientes | Toda venta tiene que estar asociada a un cliente registrado. Cada cliente se identifica de forma única por su número de DNI o CUIT. |
| RN.03 | Guardado de precio histórico | Cuando se vende un producto, se debe guardar en el detalle de la venta el precio unitario cobrado en ese momento. Si después cambia el precio del producto en el catálogo, los registros de ventas pasadas no tienen que modificarse. |
| RN.04 | Formas de pago | Toda venta debe tener una forma de pago asignada (por ejemplo efectivo, transferencia, tarjeta de crédito o débito). |
| RN.05 | Detalle de venta obligatorio | Una venta no se puede guardar vacía, debe tener por lo menos un producto asociado en su detalle. |
| RN.06 | Categorías y precios válidos | Todos los productos deben pertenecer a una categoría de hardware y tener un precio de lista mayor a cero. |
| RN.07 | Proveedores | Cada producto cargado en el sistema debe estar vinculado a un proveedor mediante su CUIT. |
