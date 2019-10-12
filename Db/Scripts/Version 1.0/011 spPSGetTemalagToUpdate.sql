-- ==========================================================================
-- Author                 : TMI, RUA Sweco
-- Create date            : 2019-08-10
-- Updated                : $Date: 2019-08-28 08:42:51 +0200 (on, 28 aug 2019) $
-- Updated by             : $Author: rua $
-- Description            : Procedure til at hente temadata lag som skal opdateres fra PowerShell
--
-- Release number         : 1.0
-- ==========================================================================
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
SET NOCOUNT ON
GO

DECLARE @svn_revision	varchar(15)	= '$Rev: 1936 $'
DECLARE @db_version		varchar(15)	= '1.0' 
DECLARE @scriptnavn		varchar(60)	= '011 spPSGetTemalagToUpdate.sql'
DECLARE @beskrivelse	varchar(250)= 'Procedure til at hente temadata lag som skal opdateres fra PowerShell'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);

----------------------------------------------------------------------------------

-- Drop Procedure if already exsisting
--DROP PROCEDURE IF EXISTS  [dbo].[spPSGetTemalagToUpdate];
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='dbo'
		  AND p.Name = 'spPSGetTemalagToUpdate')
BEGIN
    DROP PROCEDURE dbo.spPSGetTemalagToUpdate
END
go

CREATE PROCEDURE [dbo].[spPSGetTemalagToUpdate]
AS
BEGIN
	SET NOCOUNT ON;
	select ID, TEMA, SOURCEURL, TABELNAVN, IDKOLONNENAVN, GEOMKOLONNENAVN from prod.temametadata
	where AUTOOPDATERINGAKTIV = 1
	and FORVENTETOPDATERING < CURRENT_TIMESTAMP
	and SOURCEURL IS NOT NULL
END
GO

