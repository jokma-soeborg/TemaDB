



-- ==========================================================================
-- Author                 : TMI, Sweco
-- Create date            : 2020-01-12
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Fix fejl hvis tabelnavn var for langt.
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '007 spPSMoveTabelToProd.sql'
DECLARE @beskrivelse	varchar(250)= 'Fix fejl hvis tabelnavn var for langt'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO


/****** Object:  StoredProcedure [dbo].[spPSMoveTabelToProd]    Script Date: 04-02-2020 14:33:37 ******/
DROP PROCEDURE [dbo].[spPSMoveTabelToProd]
GO

/****** Object:  StoredProcedure [dbo].[spPSMoveTabelToProd]    Script Date: 04-02-2020 14:33:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[spPSMoveTabelToProd]
	@TableName	NVARCHAR(75)
AS
BEGIN
	SET NOCOUNT ON;
	declare @sql1 nvarchar(500) = 'IF OBJECT_ID(''[PROD].[' + @TableName + ']'', ''U'') IS NOT NULL 
	BEGIN
		drop table [PROD].[' + @TableName + '];
	END'	
	Execute sp_executesql @sql1
	declare @sql2 nvarchar(500) = 'ALTER SCHEMA [PROD] TRANSFER [TEMP].[' + @TableName +']';	
	Execute sp_executesql @sql2
END
GO




