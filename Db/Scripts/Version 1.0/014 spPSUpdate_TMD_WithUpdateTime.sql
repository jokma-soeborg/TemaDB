-- ==========================================================================
-- Author                 : TMI, RUA Sweco
-- Create date            : 2019-08-13
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sÃ¸, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Procedure til at opdatere last update time i TemaMetaData tabellen fra PowerShell
--
-- Release number         : 1.0
-- ==========================================================================
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
SET NOCOUNT ON
GO

DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '1.0' 
DECLARE @scriptnavn		varchar(60)	= '014 spPSUpdate_TMD_WithUpdateTime.sql'
DECLARE @beskrivelse	varchar(250)= 'Procedure til at opdatere last update time i TemaMetaData tabellen fra PowerShell'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);

----------------------------------------------------------------------------------

-- Drop Procedure if already exsisting
--DROP PROCEDURE IF EXISTS  [dbo].[spPSUpdate_TMD_WithUpdateTime];
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='dbo'
		  AND p.Name = 'spPSUpdate_TMD_WithUpdateTime')
BEGIN
    DROP PROCEDURE dbo.spPSUpdate_TMD_WithUpdateTime
END
go


CREATE PROCEDURE [dbo].[spPSUpdate_TMD_WithUpdateTime]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [PROD].[TemaMetaData] SET
	-- Kun dato, og ikke klokkeslet, for vi kan ikke være sikker på de kører på excat samme tid
	[OPDATERETDATO] = (select cast(getdate() as date))
	WHERE [ID] = @ID
END
GO



