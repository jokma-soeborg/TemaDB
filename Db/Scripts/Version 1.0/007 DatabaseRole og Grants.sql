-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-06-21
-- Updated                : $Date: 2019-08-19 15:08:18 +0200 (ma, 19 aug 2019) $
-- Updated by             : $Author: rua $
-- Description            : Databaseroles and grants
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 1899 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '007 DatabaseRole og Grants.sql'
DECLARE @beskrivelse	varchar(250)= 'Databaseroles and grants'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

USE [TemaDB]
GO

------------------------------------------------------------------------------------------------------------------
DECLARE @RoleName sysname
set @RoleName = N'RaastofKonfliktAnalyseRole'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END

IF EXISTS (select * from sys.database_principals p where name='RaastofKonfliktAnalyseRole' and type='R')
BEGIN
	DROP ROLE [RaastofKonfliktAnalyseRole]
END
GO

CREATE ROLE [RaastofKonfliktAnalyseRole]
GO

GRANT SELECT ON SCHEMA::[RIT] TO [RaastofKonfliktAnalyseRole]
GRANT INSERT ON SCHEMA::[RIT] TO [RaastofKonfliktAnalyseRole]
GRANT UPDATE ON SCHEMA::[RIT] TO [RaastofKonfliktAnalyseRole]
GRANT DELETE ON SCHEMA::[RIT] TO [RaastofKonfliktAnalyseRole]
GRANT EXECUTE ON SCHEMA::[RIT] TO [RaastofKonfliktAnalyseRole]

GRANT SELECT ON SCHEMA::[PROD] TO [RaastofKonfliktAnalyseRole]
GO

