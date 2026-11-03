
USE techgamer;
GO

-- el vendedor ve los datos de clientes tapados
PRINT '--- vendedor: clientes ---';
EXECUTE AS USER = 'usr_vendedor';
    SELECT TOP 3 id_cliente, nombre, apellido, dni, email, telefono FROM dbo.CLIENTE;
REVERT;
GO

-- el gerente los ve completos (tiene UNMASK)
PRINT '--- gerente: clientes ---';
EXECUTE AS USER = 'usr_gerente';
    SELECT TOP 3 id_cliente, nombre, apellido, dni, email, telefono FROM dbo.CLIENTE;
REVERT;
GO

-- el vendedor intenta escribir directo en las tablas, las dos tienen que fallar
PRINT '--- vendedor: update de precio ---';
EXECUTE AS USER = 'usr_vendedor';
    BEGIN TRY
        UPDATE dbo.PRODUCTO SET precio = 1.00 WHERE id_producto = 1;
        PRINT 'ERROR: lo dejo pasar';
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

PRINT '--- vendedor: insert directo en VENTA ---';
EXECUTE AS USER = 'usr_vendedor';
    BEGIN TRY
        INSERT INTO dbo.VENTA (fecha, total, id_cliente, id_empleado, id_forma_pago)
        VALUES (GETDATE(), 1.00, 1, 1, 1);
        PRINT 'ERROR: lo dejo pasar';
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

PRINT '--- vendedor: vende con el procedimiento ---';
EXECUTE AS USER = 'usr_vendedor';
    EXEC dbo.sp_RegistrarVentaCompleta
         @id_cliente = 1, @id_empleado = 1, @id_forma_pago = 1,
         @id_producto = 2, @cantidad = 1;
REVERT;
GO

-- el vendedor no puede leer la auditoria
PRINT '--- vendedor: auditoria ---';
EXECUTE AS USER = 'usr_vendedor';
    BEGIN TRY
        SELECT * FROM dbo.AUDITORIA;
        PRINT 'ERROR: lo dejo pasar';
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- el auditor si la lee (ahi aparece la venta de recien) pero no ve clientes
PRINT '--- auditor: auditoria ---';
EXECUTE AS USER = 'usr_auditor';
    SELECT TOP 5 id_auditoria, tabla, operacion, id_registro, usuario, fecha
    FROM dbo.AUDITORIA
    ORDER BY id_auditoria DESC;
REVERT;
GO

PRINT '--- auditor: clientes ---';
EXECUTE AS USER = 'usr_auditor';
    BEGIN TRY
        SELECT * FROM dbo.CLIENTE;
        PRINT 'ERROR: lo dejo pasar';
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- ni el gerente puede borrar la auditoria
PRINT '--- gerente: borrar auditoria ---';
EXECUTE AS USER = 'usr_gerente';
    BEGIN TRY
        DELETE FROM dbo.AUDITORIA;
        PRINT 'ERROR: lo dejo pasar';
    END TRY
    BEGIN CATCH
        PRINT 'Bloqueado: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- resumen de permisos por rol
SELECT dp.name AS rol,
       p.state_desc AS estado,
       p.permission_name AS permiso,
       COALESCE(OBJECT_NAME(p.major_id), 'BASE DE DATOS') AS objeto
FROM sys.database_permissions p
JOIN sys.database_principals dp ON dp.principal_id = p.grantee_principal_id
WHERE dp.name IN ('rol_vendedor', 'rol_gerente', 'rol_auditor')
ORDER BY dp.name, objeto, p.permission_name;
GO
