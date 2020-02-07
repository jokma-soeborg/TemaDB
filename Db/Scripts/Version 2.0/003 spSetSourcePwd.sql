
-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-12-28
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sÃ¸, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Update Stored procedure spSetSourcePwd
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '003 spSetSourcePwd.sql'
DECLARE @beskrivelse	varchar(250)= 'Update SP spSetSourcePwd'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO
/****** Object:  StoredProcedure [PROD].[spSetSourcePwd]    Script Date: 29-12-2019 00:07:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DROP PROCEDURE IF EXISTS PROD.spSetSourcePwd;
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='PROD'
		  AND p.Name = 'spSetSourcePwd')
BEGIN
    DROP PROCEDURE PROD.spSetSourcePwd
END
GO




/* Krypterer password og opdaterer tabellen TemaMetaData med den krypterde værdi */
CREATE PROCEDURE [PROD].[spSetSourcePwd]
	@TemaMetaDataID	UNIQUEIDENTIFIER,
	@pwd			VARCHAR(max)
AS
BEGIN	
	UPDATE prod.TemaMetaData
	SET SOURCEPWD = @pwd
	WHERE ID = @TemaMetaDataID;	
END
GO


