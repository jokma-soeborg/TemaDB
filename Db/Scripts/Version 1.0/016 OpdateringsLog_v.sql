-- ==========================================================================
-- Author                 : TMI, RUA Sweco
-- Create date            : 2019-09-02
-- Updated                : $Date: 2019-09-02 14:10:12 +0200 (ma, 02 sep 2019) $
-- Updated by             : $Author: rua $
-- Description            : View OpdateringsLog_v
--
-- Release number         : 1.0
-- ==========================================================================
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
SET NOCOUNT ON
GO

DECLARE @svn_revision	varchar(15)	= '$Rev: 1952 $'
DECLARE @db_version		varchar(15)	= '1.0' 
DECLARE @scriptnavn		varchar(60)	= '016 OpdateringsLog_v.sql'
DECLARE @beskrivelse	varchar(250)= 'View OpdateringsLog_v'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);

----------------------------------------------------------------------------------

--DROP VIEW IF EXISTS [dbo].[OpdateringsLog_v]
IF EXISTS(SELECT v.* FROM sys.views v
          WHERE v.Name = 'OpdateringsLog_v')
BEGIN
    DROP VIEW dbo.OpdateringsLog_v
END
go


CREATE VIEW [dbo].[OpdateringsLog_v]
AS
	-- Conveniance view

	select TOP 99.9  PERCENT
		m.GRUPPE, m.TEMA, m.TABELNAVN, 
		l.FEJLKODE, l.FEJLTEKST,l.OPDATERETAF, l.TIDSPUNKT
	from prod.OpdateringsLog l
	left outer join prod.TemaMetaData m on m.id=l.TEMAMETADATAID
	where l.TIDSPUNKT>DATEADD(MONTH,-3,GETDATE())
	order by l.tidspunkt desc

GO
