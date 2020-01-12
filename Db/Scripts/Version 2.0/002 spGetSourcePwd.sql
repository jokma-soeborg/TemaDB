
-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-12-28
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Stored procedure spDecryptPwd
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '002 spGetSourcePwd.sql'
DECLARE @beskrivelse	varchar(250)= 'Update SP spGetSourcePwd'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

--DROP PROCEDURE IF EXISTS PROD.spGetSourcePwd;
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='PROD'
		  AND p.Name = 'spGetSourcePwd')
BEGIN
    DROP PROCEDURE PROD.spGetSourcePwd
END
GO

CREATE PROCEDURE [PROD].[spGetSourcePwd]
	@TemaMetaDataID	UNIQUEIDENTIFIER,
	@pwd			VARCHAR(max)			OUTPUT
AS
BEGIN
	SELECT @PWD = [SOURCEPWD]
	FROM prod.TEMAMETADATA
	WHERE ID = @TemaMetaDataID
END
GO


