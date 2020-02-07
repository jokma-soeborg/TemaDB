-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-06-13 
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Create user for temadatabase remote adgang
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '003 Create User.sql'
DECLARE @beskrivelse	varchar(250)= 'Create temadatabase'


-------------------------------------------------------------------------------------------------------------------------
USE [master]
GO

IF EXISTS (select 1 from [sys].[server_principals] where name='RaastofTemaDBLogin')
BEGIN
	exec sp_dropuser 'RaastofTemaDBLogin'
END

CREATE LOGIN [RaastofTemaDBLogin] WITH PASSWORD=N'Qwerty12345', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-------------------------------------------------------------------------------------------------------------------------
USE [TemaDB]
GO

CREATE USER [RaastofTemaDBLogin] FOR LOGIN [RaastofTemaDBLogin]
GO

ALTER ROLE [db_owner] ADD MEMBER [RaastofTemaDBLogin]
GO

