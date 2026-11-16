# Descripción del caso y alcance — Etapa 1

**Equipo:** 07
**Integrantes:** Aranda Gabriel Angel, Roa Gabriel Alan, Miño Maidana Ulises Ivan, Gon Victoria Raquel, Bonessi Luis Maria
**Tema:** Sistema de gestión de ventas de componentes y hardware Gamer (TechGamer DB)

## 1. Descripción del caso

El proyecto consiste en el diseño de una base de datos para un local dedicado a la venta de componentes informáticos y hardware enfocado en gaming y PCs de alto rendimiento.

El sistema busca llevar el control de los productos que se venden en el local, gestionar el stock disponible en inventario, registrar los datos de los clientes que compran y guardar un historial de cada venta realizada.

Debido a que los precios de la tecnología cambian constantemente, es necesario que la base de datos guarde el precio exacto al que se vendió cada componente en el momento de la transacción. De esta manera, si después se actualiza el precio del producto en la lista general, no cambia el total de las ventas que ya se hicieron antes.

## 2. Alcance del sistema

El sistema tendrá las siguientes funciones principales:

- Registro de productos de hardware (placas de video, procesadores, memorias RAM, etc.) y su clasificación por categorías.
- Control del stock de productos para saber cuántas unidades quedan disponibles.
- Registro de clientes con sus datos personales principales.
- Generación de ventas donde se asocie el cliente, el vendedor, la fecha y la forma de pago.
- Detalle de los productos vendidos en cada venta, guardando la cantidad y el precio al que se cobró en ese momento.
- Registro de proveedores que suministran los componentes.

## 3. Actores

| Actor | Participación en el sistema |
|---|---|
| Cliente | Compra productos y queda registrado con sus datos personales. |
| Empleado (vendedor) | Registra las ventas del local. |
| Proveedor | Suministra los componentes que se venden. |
