



-- ==========================================================================
-- Author                 : TMI, Sweco
-- Create date            : 2020-01-12
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Slet ikke benyttede encryption certificates etc.
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '2.0'
DECLARE @scriptnavn		varchar(60)	= '005 Slet Certs.sql'
DECLARE @beskrivelse	varchar(250)= 'Slet ikke benyttede encryption certificates etc.'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

-- Delete Symettric Key, that is no longer used
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'SourcePwd_Key')  
BEGIN
	DROP SYMMETRIC KEY SourcePwd_Key		
	PRINT 'Symmetric key Slettet'
END

-- Delete TemaDb Certificate, that is no longer used
IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'TemaDBCert')  
BEGIN
	DROP CERTIFICATE TemaDBCert 
	PRINT 'Certifikat Slettet'
END

-- Detele Master Key, that is no longer used
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)  
BEGIN    	
	DROP MASTER KEY
	PRINT 'Database master key Slettet'
END
