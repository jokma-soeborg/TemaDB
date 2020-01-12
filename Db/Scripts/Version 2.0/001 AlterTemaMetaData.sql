
-- ==========================================================================
-- Author                 : TMI, Sweco
-- Create date            : 2019-12-28
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Stored procedure spDecryptPwd
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '001 AlterTemaMetaData.sql'
DECLARE @beskrivelse	varchar(250)= 'Change password column'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

-- Drop Password Column
ALTER TABLE [PROD].[TemaMetaData] DROP COLUMN SOURCEPWD;
GO

-- Readd column as VarChar
ALTER TABLE [PROD].[TemaMetaData] ADD SOURCEPWD [varchar](max) NULL;
GO
