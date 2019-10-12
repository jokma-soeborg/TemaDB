-- ==========================================================================
-- Author                 : TMI, RUA Sweco
-- Create date            : 2019-08-13
-- Updated                : $Date: 2019-08-16 14:37:23 +0200 (fr, 16 aug 2019) $
-- Updated by             : $Author: rua $
-- Description            : Procedure til lave et logentry fra PowerShell
--
-- Release number         : 1.0
-- ==========================================================================
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
SET NOCOUNT ON
GO

DECLARE @svn_revision	varchar(15)	= '$Rev: 1884 $'
DECLARE @db_version		varchar(15)	= '1.0' 
DECLARE @scriptnavn		varchar(60)	= '012 spPSLogEntry.sql'
DECLARE @beskrivelse	varchar(250)= 'Procedure til lave et logentry fra PowerShell'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);

----------------------------------------------------------------------------------

-- Drop Procedure if already exsisting
--DROP PROCEDURE IF EXISTS [dbo].[spPSLogEntry]
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='dbo'
		  AND p.Name = 'spPSLogEntry')
BEGIN
    DROP PROCEDURE dbo.spPSLogEntry
END
go


CREATE PROCEDURE [dbo].[spPSLogEntry]
	 @TEMAMETADATAID	UNIQUEIDENTIFIER
	,@FEJLKODE			INT
	,@FEJLTEKST			VARCHAR(1000)
	,@OPDATERETAF		VARCHAR(100)

AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [PROD].[OpdateringsLog] (
		 TEMAMETADATAID
		,FEJLKODE
		,FEJLTEKST
		,OPDATERETAF
		, TIDSPUNKT)
		 
		VALUES (
			 @TEMAMETADATAID
			,@FEJLKODE
			,@FEJLTEKST
			,@OPDATERETAF
			, CURRENT_TIMESTAMP
			)

END
GO

