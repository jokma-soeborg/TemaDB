
-- ==========================================================================
-- Author                 : TMI, Sweco
-- Create date            : 2020-01-12
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Update Kommunegrænser URL
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '004 Update Kommunegraenser URL.sql'
DECLARE @beskrivelse	varchar(250)= 'Update Kommunegrænser URL'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

UPDATE [PROD].[TemaMetaData]
SET [SOURCEURL] = 'ftp://ftp.kortforsyningen.dk/landinddelinger/dagi/SHAPE/DAGIREF_SHAPE_UTM32-EUREF89.zip'
WHERE [ID] = 'EA4ADE67-D98E-4E7B-BEDB-22C63F704B46'
GO
