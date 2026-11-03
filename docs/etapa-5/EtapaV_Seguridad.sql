
-- ETAPA V - SEGURIDAD (SQL Server)
-- Autenticación (logins), autorización (usuarios, roles, GRANT/DENY) y
-- protección de datos sensibles (Dynamic Data Masking).
-- Ejecutar DESPUÉS de DDL, DML, EtapaV_Procedimientos_Funciones.sql y
-- EtapaV_Triggers_Auditoria.sql.

-- 1. LOGINS (nivel servidor)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_vendedor')
    CREATE LOGIN login_vendedor
        WITH PASSWORD = 'Vend#TechGamer2026!', CHECK_POLICY = ON, DEFAULT_DATABASE = techgamer;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_gerente')
    CREATE LOGIN login_gerente
        WITH PASSWORD = 'Ger#TechGamer2026!', CHECK_POLICY = ON, DEFAULT_DATABASE = techgamer;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_auditor')
    CREATE LOGIN login_auditor
        WITH PASSWORD = 'Aud#TechGamer2026!', CHECK_POLICY = ON, DEFAULT_DATABASE = techgamer;
GO

-- 2. USUARIOS (nivel base de datos): qué login entra a techgamer
USE techgamer;
GO

IF USER_ID('usr_vendedor') IS NOT NULL DROP USER usr_vendedor;
IF USER_ID('usr_gerente')  IS NOT NULL DROP USER usr_gerente;
IF USER_ID('usr_auditor')  IS NOT NULL DROP USER usr_auditor;
GO

CREATE USER usr_vendedor FOR LOGIN login_vendedor;
CREATE USER usr_gerente  FOR LOGIN login_gerente;
CREATE USER usr_auditor  FOR LOGIN login_auditor;
GO

-- 3. ROLES: grupos de permisos según la función (mínimo privilegio)
IF DATABASE_PRINCIPAL_ID('rol_vendedor') IS NOT NULL
BEGIN
    IF IS_ROLEMEMBER('rol_vendedor', 'usr_vendedor') = 1 ALTER ROLE rol_vendedor DROP MEMBER usr_vendedor;
    DROP ROLE rol_vendedor;
END
IF DATABASE_PRINCIPAL_ID('rol_gerente') IS NOT NULL
BEGIN
    IF IS_ROLEMEMBER('rol_gerente', 'usr_gerente') = 1 ALTER ROLE rol_gerente DROP MEMBER usr_gerente;
    DROP ROLE rol_gerente;
END
IF DATABASE_PRINCIPAL_ID('rol_auditor') IS NOT NULL
BEGIN
    IF IS_ROLEMEMBER('rol_auditor', 'usr_auditor') = 1 ALTER ROLE rol_auditor DROP MEMBER usr_auditor;
    DROP ROLE rol_auditor;
END
GO

CREATE ROLE rol_vendedor;
CREATE ROLE rol_gerente;
CREATE ROLE rol_auditor;
GO

ALTER ROLE rol_vendedor ADD MEMBER usr_vendedor;
ALTER ROLE rol_gerente  ADD MEMBER usr_gerente;
ALTER ROLE rol_auditor  ADD MEMBER usr_auditor;
GO

    
-- 4. PERMISOS
-- Vendedor: consulta catalogo y clientes; vende SOLO mediante el procedimiento
GRANT SELECT ON dbo.PRODUCTO    TO rol_vendedor;
GRANT SELECT ON dbo.CATEGORIA   TO rol_vendedor;
GRANT SELECT ON dbo.CLIENTE     TO rol_vendedor;   
GRANT SELECT ON dbo.FORMA_PAGO  TO rol_vendedor;
GRANT EXECUTE ON dbo.sp_RegistrarVentaCompleta TO rol_vendedor;
GRANT EXECUTE ON dbo.fn_CalcularDescuentoCliente TO rol_vendedor;

-- Sin acceso directo para modificar ventas, detalle ni productos
DENY INSERT, UPDATE, DELETE ON dbo.VENTA         TO rol_vendedor;
DENY INSERT, UPDATE, DELETE ON dbo.DETALLE_VENTA TO rol_vendedor;
DENY INSERT, UPDATE, DELETE ON dbo.PRODUCTO      TO rol_vendedor;
DENY SELECT ON dbo.AUDITORIA TO rol_vendedor;
DENY SELECT ON dbo.EMPLEADO  TO rol_vendedor;

-- Gerente: lee todo y puede vender; no modifica la estructura
ALTER ROLE db_datareader ADD MEMBER usr_gerente;
GRANT EXECUTE ON dbo.sp_RegistrarVentaCompleta TO rol_gerente;
GRANT EXECUTE ON dbo.fn_CalcularDescuentoCliente TO rol_gerente;
GRANT UNMASK TO rol_gerente;   -- el gerente ve los datos de clientes sin enmascarar
DENY INSERT, UPDATE, DELETE ON dbo.AUDITORIA TO rol_gerente;

-- ---- Auditor: lee únicamente la auditoría
GRANT SELECT ON dbo.AUDITORIA TO rol_auditor;
DENY  SELECT ON dbo.CLIENTE   TO rol_auditor;
DENY  INSERT, UPDATE, DELETE ON dbo.AUDITORIA TO rol_auditor;
GO

-- 5. ENMASCARAMIENTO DE DATOS SENSIBLES
-- Los usuarios sin permiso UNMASK ven los datos ocultos parcialmente.
ALTER TABLE dbo.CLIENTE ALTER COLUMN dni      ADD MASKED WITH (FUNCTION = 'partial(0, "XXXX", 4)');
ALTER TABLE dbo.CLIENTE ALTER COLUMN email    ADD MASKED WITH (FUNCTION = 'email()');
ALTER TABLE dbo.CLIENTE ALTER COLUMN telefono ADD MASKED WITH (FUNCTION = 'partial(0, "XXX-XXX-", 4)');
GO

-- 6. DEMOSTRACIÓN
-- EXECUTE AS simula ser otro usuario; REVERT vuelve al usuario original.

-- 6.1 Vendedor: ve clientes con datos enmascarados
EXECUTE AS USER = 'usr_vendedor';
    SELECT TOP 3 id_cliente, nombre, apellido, dni, email, telefono FROM dbo.CLIENTE;
REVERT;
GO

-- 6.2 Gerente: ve los datos completos
EXECUTE AS USER = 'usr_gerente';
    SELECT TOP 3 id_cliente, nombre, apellido, dni, email, telefono FROM dbo.CLIENTE;
REVERT;
GO

-- 6.3 Vendedor: intenta modificar un precio directamente (debe FALLAR: permiso denegado)
EXECUTE AS USER = 'usr_vendedor';
    BEGIN TRY
        UPDATE dbo.PRODUCTO SET precio = 1.00 WHERE id_producto = 1;
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado correctamente: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- 6.4 Vendedor: registra una venta mediante el procedimiento (debe FUNCIONAR)
EXECUTE AS USER = 'usr_vendedor';
    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 2, @cantidad = 1;
REVERT;
GO

-- 6.5 Vendedor: intenta ver la auditoría (debe FALLAR)
EXECUTE AS USER = 'usr_vendedor';
    BEGIN TRY
        SELECT * FROM dbo.AUDITORIA;
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado correctamente: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- 6.6 Auditor: lee la auditoría (debe FUNCIONAR) y no puede ver clientes (debe FALLAR)
EXECUTE AS USER = 'usr_auditor';
    SELECT TOP 5 * FROM dbo.AUDITORIA ORDER BY id_auditoria DESC;
    BEGIN TRY
        SELECT * FROM dbo.CLIENTE;
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado correctamente: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- 6.7 Resumen de permisos asignados
SELECT dp.name AS principal, p.permission_name, p.state_desc,
       COALESCE(OBJECT_NAME(p.major_id), 'BASE DE DATOS') AS objeto
FROM sys.database_permissions p
JOIN sys.database_principals dp ON dp.principal_id = p.grantee_principal_id
WHERE dp.name IN ('rol_vendedor', 'rol_gerente', 'rol_auditor')
ORDER BY dp.name, objeto, p.permission_name;
GO
