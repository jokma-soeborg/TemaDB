



-- ==========================================================================
-- Author                 : TMI, Sweco
-- Create date            : 2020-01-12
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Ændret så brugernavn også hentes med ud.
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '006 spPSGetTemalagToUpdate.sql'
DECLARE @beskrivelse	varchar(250)= 'Ændret så brugernavn også hentes med ud.'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

/****** Object:  StoredProcedure [dbo].[spPSGetTemalagToUpdate]    Script Date: 04-02-2020 14:30:11 ******/
DROP PROCEDURE [dbo].[spPSGetTemalagToUpdate]
GO

/****** Object:  StoredProcedure [dbo].[spPSGetTemalagToUpdate]    Script Date: 04-02-2020 14:30:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[spPSGetTemalagToUpdate]
AS
BEGIN
	SET NOCOUNT ON;
	select ID, TEMA, SOURCEURL, TABELNAVN, IDKOLONNENAVN, GEOMKOLONNENAVN, SOURCEUSER from prod.temametadata
	where AUTOOPDATERINGAKTIV = 1
	and ((FORVENTETOPDATERING < CURRENT_TIMESTAMP
	and SOURCEURL IS NOT NULL)
	or SOURCEURL like 'fil:%')
END
GO

