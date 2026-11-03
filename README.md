# proyecto-bd1-equipo_07-
### Proyecto — Bases de Datos 1

# TechGamer
TechGamer es un proyecto de diseño e implementación de una base de datos relacional para administrar las operaciones de una tienda de productos tecnologicos y perifericos gamer. El sistema permite organizar el catalogo, los proveedores, los clientes, los empleados, las formas de pago y las ventas, ademas de incorporar mecanismos de validación, optimización, seguridad y auditoria

---

## Integrantes del equipo

| N.º | Apellido y nombre | DNI |

| 1 | Roa Gabriel Alan      | [43346673] |

| 2 | Gon Victoria Raquel   | [46776550] |

| 3 | Miño Maidana Ulises Ivan | [45526629] |

| 4 | Bonessi Luis Maria | [46773971] |

| 5 | Aranda Gabriel Angel | [46714612] |

---

## 1. Objetivo y alcance

El objetivo es modelar una base de datos que represente el funcionamiento básico de un comercio de tecnologia.
El proyecto contempla el ciclo habitual de desarrollo de una base de datos:

1. Analisis del problema y modelado conceptual
2. Diseño del modelo relacional y normalización
3. Implementación física mediante tablas y restricciones
4. Carga de datos y pruebas de validación
5. Incorporación de procedimientos, funciones, transacciones, triggers, índices y mecanismos de seguridad

La entrega se centra en la capa de datos: no incluye una aplicación gráfica o interfaz de usuario.

## 2. ¿Cómo funciona?

La información se distribuye en ocho tablas relacionadas:

- **CATEGORIA:** clasifica los productos comercializados
- **PROVEEDOR:** almacena los datos de las empresas proveedoras
- **PRODUCTO:** contiene el catalogo, los precios, el stock y las referencias a categoría y proveedor
- **CLIENTE:** registra los datos de las personas que realizan compras
- **EMPLEADO:** almacena los empleados que intervienen en las ventas
- **FORMA_PAGO:** contiene los medios de pago disponibles
- **VENTA:** registra la operacion comercial, su fecha, total, cliente, empleado y forma de pago
- **DETALLE_VENTA:** identifica los productos incluidos en cada venta, junto con su cantidad y precio unitario

Una venta se vincula con un cliente, un empleado y una forma de pago. A su vez, una venta puede contener varios detalles, y cada detalle referencia un producto. De esta manera se representa la relación de muchos a muchos entre ventas y productos mediante la tabla intermedia `DETALLE_VENTA`

### Relaciones principales

| Relación | Cardinalidad |
| CATEGORIA — PRODUCTO | Una categoría puede tener muchos productos. |
| PROVEEDOR — PRODUCTO | Un proveedor puede suministrar muchos productos. |
| CLIENTE — VENTA | Un cliente puede realizar muchas ventas. |
| EMPLEADO — VENTA | Un empleado puede registrar muchas ventas. |
| FORMA_PAGO — VENTA | Una forma de pago puede utilizarse en muchas ventas. |
| VENTA — DETALLE_VENTA | Una venta puede contener varios detalles. |
| PRODUCTO — DETALLE_VENTA | Un producto puede aparecer en muchos detalles de venta. |

El modelo entidad-relación y los diagramas se encuentran en la carpeta `modelos/` y en la documentación de las etapas.

## 3. Estructura del proyecto

```text
proyecto-bd1-equipo_07/
├── README.md
├── modelos/
│   ├── TechGamer(Conceptual).png
│   ├── TechGamer(DER).png
│   └── archivos de modelado ER
├── sql/
│   ├── ddl/
│   │   └── DDL_techgamer.sql
│   ├── dml/
│   │   └── DML_techgamer.sql
│   └── ETAPA4PRUEBA.SQL
└── docs/
    ├── etapa-01/
    ├── etapa-2/
    ├── etapa-3/
    ├── etapa-4/
    └── etapa-5/
        ├── EtapaV_Procedimientos_Funciones.sql
        ├── EtapaV_Transacciones_Implementacion.sql
        ├── EtapaV_Transacciones_Demostracion.sql
        ├── EtapaV_Triggers_Auditoria.sql
        ├── EtapaV_Triggers_Auditoria_Alternativa.sql
        ├── EtapaV_Triggers_Demo.sql
        ├── EtapaV_Triggers_Demo_Alternativa.sql
        ├── EtapaV_Indices.sql
        └── EtapaV_Seguridad.sql
```

La carpeta `docs/` contiene la documentación y los scripts de las distintas etapas. Los archivos alternativos de auditoría y demostración son variantes: no es necesario ejecutar ambas versiones.

## 4. Instalación y puesta en marcha

### Requisitos

- Microsoft SQL Server.
- SQL Server Management Studio (SSMS) o una herramienta compatible para ejecutar scripts T-SQL.
- Permisos suficientes para crear bases de datos, tablas, procedimientos, triggers, índices, logins y usuarios (según las etapas que se quieran ejecutar).

### Orden recomendado de ejecución

Abrir los scripts en la herramienta de administración de SQL Server y ejecutarlos en este orden:

1. `sql/ddl/DDL_techgamer.sql` — crea la base `techgamer` y sus tablas.
2. `sql/dml/DML_techgamer.sql` — carga los datos iniciales de ejemplo.
3. `docs/etapa-5/EtapaV_Procedimientos_Funciones.sql` — crea la función de descuentos y el procedimiento de venta simple.
4. `docs/etapa-5/EtapaV_Transacciones_Implementacion.sql` — crea el tipo de tabla y el procedimiento para ventas con varios productos.
5. **Una sola** variante de auditoría:
   - `EtapaV_Triggers_Auditoria.sql`, o
   - `EtapaV_Triggers_Auditoria_Alternativa.sql`.
6. `docs/etapa-5/EtapaV_Indices.sql` — crea índices y ejecuta una demostración de rendimiento.
7. `docs/etapa-5/EtapaV_Seguridad.sql` — configura logins, usuarios, roles y enmascaramiento.
8. Los scripts `EtapaV_Transacciones_Demostracion.sql` y `EtapaV_Triggers_Demo.sql` (o sus variantes) sirven para probar los comportamientos implementados.

Los archivos de demostración deben ejecutarse después de crear los objetos que utilizan. Las pruebas de etapas anteriores están documentadas en `docs/etapa-3/Pruebas_de_Validacion.md` y en los scripts de `docs/etapa-4/`.


## 5. Funciones y lógica de negocio

### Función `fn_CalcularDescuentoCliente`

Recibe el identificador de un cliente y calcula el porcentaje de descuento según la suma de los totales de sus ventas registradas:

| Total acumulado del cliente | Descuento |
|---:|---:|
| Hasta $200.000 inclusive | 0 % |
| Más de $200.000 y hasta $500.000 inclusive | 5 % |
| Más de $500.000 | 10 % |

La función devuelve el porcentaje como un valor decimal (por ejemplo, `0.10` representa un 10 %). Se utiliza para calcular el importe final de nuevas ventas.

### Procedimiento `sp_RegistrarVentaCompleta`

Registra una venta de un solo producto. Recibe cliente, empleado, forma de pago, producto y cantidad. Comprueba que la cantidad sea válida, que el producto exista y que haya stock suficiente. Luego calcula el descuento, inserta la cabecera en `VENTA`, agrega el registro correspondiente en `DETALLE_VENTA` y descuenta las unidades del stock.

### Procedimiento `sp_RegistrarVentaMultiple`

Permite registrar una venta con varios productos en una sola operación. Recibe un parámetro de tipo tabla (`dbo.TipoDetalleVenta`) con los identificadores de productos y sus cantidades.

El procedimiento valida que el detalle no esté vacío, que todos los productos existan y que haya stock suficiente. Calcula el subtotal y el descuento, registra la venta y sus detalles y actualiza el stock de todos los productos. Utiliza una transacción, `TRY/CATCH`, `XACT_ABORT` y bloqueos (`UPDLOCK`, `HOLDLOCK`) para proteger la operación ante errores y concurrencia.

## 6. Transacciones y consistencia

Una transacción agrupa varias instrucciones para que se ejecuten como una unidad lógica. En el registro de una venta, no sería correcto guardar la cabecera y los detalles si luego falla la actualización del stock.

Por eso, el procedimiento de venta múltiple utiliza:

- `BEGIN TRANSACTION`: inicia la operación.
- `COMMIT TRANSACTION`: confirma todos los cambios.
- `ROLLBACK TRANSACTION`: revierte los cambios si ocurre un error.
- `TRY/CATCH` y `THROW`: permiten detectar y comunicar errores.
- `SET XACT_ABORT ON`: hace que determinados errores de ejecución cancelen la transacción.
- `UPDLOCK` y `HOLDLOCK`: ayudan a evitar que otras operaciones modifiquen el stock leído antes de confirmar la venta.

Así se busca mantener la consistencia entre ventas, detalles y existencias.

## 7. Triggers y auditoría

Los triggers son acciones que SQL Server ejecuta automáticamente ante determinados eventos de una tabla.

El proyecto incorpora triggers `AFTER INSERT, UPDATE, DELETE` para registrar cambios en:

- `VENTA`
- `DETALLE_VENTA`
- `PRODUCTO`

La tabla `AUDITORIA` almacena la tabla afectada, el tipo de operación, el identificador del registro, los datos anteriores, los datos nuevos, el usuario y la fecha. Los datos anteriores y nuevos se serializan en formato JSON.

También se incorpora un trigger `INSTEAD OF UPDATE, DELETE` para impedir que se modifique o elimine directamente el historial de auditoría.

En la variante alternativa, los cambios de `PRODUCTO` se registran cuando se modifica el nombre, el precio o el stock, evitando registrar actualizaciones sin cambios efectivos en esos campos.

## 8. Índices y optimización

Los índices permiten localizar registros con mayor eficiencia y pueden reducir las lecturas necesarias para determinadas consultas. El proyecto combina índices generados por restricciones con índices no agrupados creados explícitamente.

Entre los índices adicionales se incluyen:

- Búsquedas de ventas por cliente y por fecha.
- Consultas de ventas por empleado.
- Búsquedas de detalles por producto.
- Listados de productos por categoría o proveedor.
- Búsquedas de productos por nombre.
- Búsquedas de clientes por apellido y nombre.
- Consultas del historial de auditoría por tabla, registro y fecha.
- Un índice filtrado para productos cuyo stock es menor o igual a 10.

El script de índices también crea temporalmente una tabla de prueba con 200.000 ventas y compara las lecturas lógicas y el tiempo de consulta antes y después de crear un índice. La tabla de prueba se elimina al finalizar.

Un índice mejora determinadas lecturas, pero ocupa espacio y agrega trabajo a las operaciones de inserción, actualización y eliminación. Por eso debe elegirse según las consultas que realmente se ejecutan.

## 9. Seguridad y permisos

La etapa de seguridad demuestra los conceptos de autenticación y autorización mediante logins de SQL Server, usuarios de base de datos y roles.

Se definen tres perfiles:

| Rol | Responsabilidades y permisos principales |
|---|---|
| `rol_vendedor` | Consulta el catálogo y los clientes; registra ventas mediante el procedimiento autorizado. No puede modificar directamente ventas, detalles o productos ni consultar la auditoría. |
| `rol_gerente` | Puede leer la información general y ejecutar las operaciones de venta. Tiene permiso `UNMASK` para consultar los datos completos de clientes. |
| `rol_auditor` | Puede consultar la tabla `AUDITORIA`, pero no acceder a los datos de clientes ni modificar el historial. |

También se utiliza **Dynamic Data Masking** para ocultar parcialmente DNI, email y teléfono a los usuarios que no poseen el permiso `UNMASK`.

La asignación de permisos aplica el principio de mínimo privilegio: cada perfil recibe solamente los accesos necesarios para su función.

## 10. Integridad y validaciones

La base aplica distintas reglas para evitar datos inválidos:

- **Integridad de entidad:** cada tabla tiene una clave primaria (`PRIMARY KEY`) que identifica sus registros.
- **Integridad referencial:** las claves foráneas (`FOREIGN KEY`) impiden referencias a registros inexistentes.
- **Integridad de dominio:** tipos de datos, `NOT NULL` y restricciones `CHECK` controlan los valores permitidos.
- **Unicidad:** restricciones `UNIQUE` evitan duplicados en datos como DNI, CUIL, legajo y nombres de categorías.
- **Valores por defecto:** `DEFAULT` asigna stock inicial `0` y fecha de venta mediante `GETDATE()` cuando no se informa otro valor.

Algunos controles concretos son: precio de producto mayor que cero, stock no negativo, total de venta no negativo, cantidad de detalle mayor que cero y precio unitario positivo. También se validan formatos de DNI, CUIL y email mediante restricciones `CHECK`.

En cuanto a las acciones referenciales, las relaciones principales utilizan `ON DELETE NO ACTION`, mientras que los detalles se eliminan en cascada cuando se elimina su venta (`ON DELETE CASCADE`). Las claves relacionadas utilizan `ON UPDATE CASCADE`.

## 11. Normalización y conceptos teóricos

El diseño relacional busca reducir la redundancia y evitar anomalías de inserción, actualización y eliminación.

- **Primera Forma Normal (1FN):** cada atributo contiene valores atómicos y no se guardan listas de productos dentro de una venta. Se separa el detalle de la venta para representar sus múltiples productos.
- **Segunda Forma Normal (2FN):** se eliminan dependencias parciales respecto de claves compuestas. Por ejemplo, el nombre del producto pertenece a `PRODUCTO` y no al detalle de venta, porque depende del producto y no de la combinación venta-producto.
- **Tercera Forma Normal (3FN):** se evitan dependencias transitivas entre atributos que no son clave. La documentación del proyecto concluye que, luego de los ajustes anteriores, no se requieren nuevas separaciones para alcanzar esta forma normal.

Otros conceptos aplicados:

- **Modelo entidad-relación (DER):** representa entidades, atributos y relaciones antes de implementar las tablas.
- **Claves primarias y foráneas:** identifican registros y conectan las entidades.
- **Cardinalidad:** expresa cuántas instancias de una entidad pueden relacionarse con otra.
- **Restricciones de integridad:** protegen la validez de los datos.
- **Procedimientos y funciones:** encapsulan lógica reutilizable en el servidor.
- **Triggers:** automatizan acciones ante cambios en tablas.
- **Transacciones y propiedades ACID:** buscan atomicidad, consistencia, aislamiento y durabilidad.
- **Índices:** estructuras auxiliares que aceleran búsquedas y consultas.
- **Roles y privilegios:** organizan el acceso seguro a los objetos de la base.

La documentación específica de las decisiones de diseño y de cada forma normal se encuentra en `docs/etapa-2/`.

## 12. Pruebas

El proyecto incluye pruebas para verificar tanto los datos como las reglas de negocio. Entre ellas:

- Recuento de registros cargados en cada tabla.
- Consultas con `INNER JOIN` para comprobar relaciones entre productos, categorías, proveedores, ventas, clientes y empleados.
- Verificación de totales de venta y detalles.
- Control de stock y detección de valores negativos.
- Detección de DNI, CUIL, legajos y otros valores duplicados.
- Intentos de insertar referencias inexistentes y valores fuera de los dominios permitidos.
- Demostraciones de transacciones, auditoría y permisos.

Los resultados esperados y varias consultas de validación están explicados en `docs/etapa-3/Pruebas_de_Validacion.md`. Las demostraciones de la etapa 5 se encuentran junto a sus respectivos scripts.

## 13. Consideraciones técnicas

- El proyecto está escrito para **SQL Server** y utiliza elementos propios de T-SQL, como `GO`, `IDENTITY`, `CREATE OR ALTER`, `THROW`, `RAISERROR`, `EXECUTE AS` y `FOR JSON`.
- Los scripts deben ejecutarse en el orden indicado y con los permisos correspondientes.
- Los archivos de demostración pueden insertar ventas, modificar precios o stock y generar registros de auditoría. Conviene ejecutarlos en una base de pruebas.
- La demostración de borrado dentro de una transacción utiliza `ROLLBACK` para conservar los datos.
- El script principal de DDL recrea la base de datos desde cero; realizar una copia de seguridad antes de volver a ejecutarlo.

---

## Conclusion Final

El desarrollo del proyecto TechGamer permitió poner en práctica e integrar los principales conceptos estudiados en la materia Bases de Datos 1, comprendiendo la importancia de diseñar, implementar y administrar una base de datos relacional de manera estructurada, eficiente y segura.

A lo largo de las distintas etapas se trabajó con el modelado entidad-relación, la transformación al modelo relacional y la normalización, aplicando las formas normales para reducir la redundancia, evitar inconsistencias y garantizar una correcta organización de la información. También se profundizó en el uso de claves primarias y foráneas, restricciones de integridad y relaciones entre tablas, elementos fundamentales para mantener la coherencia de los datos.

La implementación de procedimientos almacenados, funciones y triggers permitió comprender cómo centralizar y automatizar la lógica de negocio dentro del motor de base de datos. Por otra parte, el uso de transacciones demostró la importancia de las propiedades ACID para garantizar que operaciones críticas, como el registro de una venta y la actualización del stock, se ejecuten de manera íntegra y consistente, incluso cuando se producen errores.

Asimismo, la incorporación de índices permitió analizar cómo optimizar las consultas y mejorar el rendimiento, mientras que la implementación de usuarios, roles, permisos y enmascaramiento de datos permitió reconocer la importancia de la seguridad y del control de acceso a la información.

En conclusión, TechGamer no solo representa la implementación de una base de datos para un escenario comercial, sino también la integración de conocimientos fundamentales para el desarrollo de sistemas de información confiables. Los conceptos aprendidos demuestran que una base de datos no consiste únicamente en almacenar información, sino en garantizar que esta sea correcta, consistente, accesible, segura y eficiente. Estos principios constituyen la base para desarrollar soluciones tecnológicas capaces de responder a las necesidades de organizaciones y sistemas reales.
