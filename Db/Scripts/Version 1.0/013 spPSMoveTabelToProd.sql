-- ==========================================================================
-- Author                 : TMI, RUA Sweco
-- Create date            : 2019-08-12
-- Updated                : $Date: 2019-09-03 17:19:47 +0200 (ti, 03 sep 2019) $
-- Updated by             : $Author: rua $
-- Description            : Procedure til at flytte en tabel fra TEMP skema til PROD skema fra PowerShell
--
-- Release number         : 1.0
-- ==========================================================================
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
SET NOCOUNT ON
GO

DECLARE @svn_revision	varchar(15)	= '$Rev: 1955 $'
DECLARE @db_version		varchar(15)	= '1.0' 
DECLARE @scriptnavn		varchar(60)	= '013 spPSMoveTabelToProd.sql'
DECLARE @beskrivelse	varchar(250)= 'Procedure til at flytte en tabel fra temp skema til prod skema fra PowerShell'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);

----------------------------------------------------------------------------------

-- Drop Procedure if already exsisting
--DROP PROCEDURE IF EXISTS  [dbo].[spPSMoveTabelToProd]
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='dbo'
		  AND p.Name = 'spPSMoveTabelToProd')
BEGIN
    DROP PROCEDURE dbo.spPSMoveTabelToProd
END
go


CREATE PROCEDURE [dbo].[spPSMoveTabelToProd]
	@TableName	VARCHAR(75)
AS
BEGIN
	SET NOCOUNT ON;
	declare @sql1 nvarchar(100) = 'IF OBJECT_ID(''[PROD].[' + +@TableName + ']'', ''U'') IS NOT NULL
	drop table [PROD].[' +@TableName +']';
	Execute sp_executesql @sql1
	declare @sql2 nvarchar(500) = 'ALTER SCHEMA [PROD] TRANSFER [TEMP].[' +@TableName +']';
	Execute sp_executesql @sql2
END
GO



