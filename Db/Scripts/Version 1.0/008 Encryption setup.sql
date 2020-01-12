USE [TemaDB]
GO
-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-08-08
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sÃ¸, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Encryption setup
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '008 Encryption setup.sql'
DECLARE @beskrivelse	varchar(250)= 'Encryption setup'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

-- Password i tabellen TemaMetaData kryptyeres med en symetric key.
-- til dette formål oprettes keys og certifictes her.
--

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)  
BEGIN
    CREATE MASTER KEY ENCRYPTION BY   
    PASSWORD = '23987hxJKL95QYV4369#ghf0%lekjg5k3fd117r$$#1946kcj$n44ncjhdlj'  

	PRINT 'Database master key oprettet'
END
ELSE
BEGIN
	PRINT 'Database master key finde allerede'
END
GO  

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'TemaDBCert')  
BEGIN
	CREATE CERTIFICATE TemaDBCert 
	WITH SUBJECT = 'Password for Temadata source';  

	PRINT 'Certifikat oprettet'
END
ELSE
BEGIN
	PRINT 'Certifikat findes allerede'
END
GO  

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'SourcePwd_Key')  
BEGIN
	CREATE SYMMETRIC KEY SourcePwd_Key
		WITH ALGORITHM = AES_256  
		ENCRYPTION BY CERTIFICATE TemaDBCert;  

	PRINT 'Symmetric key Oprettet'
END
ELSE
BEGIN
	PRINT 'Symmetric key findes allerede'
END
GO  