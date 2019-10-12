USE [TemaDB]
GO
-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-08-08
-- Updated                : $Date: 2019-08-08 13:31:38 +0200 (to, 08 aug 2019) $
-- Updated by             : $Author: rua $
-- Description            : Encryption setup
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 1855 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '008 Encryption setup.sql'
DECLARE @beskrivelse	varchar(250)= 'Encryption setup'

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

-- Password i tabellen TemaMetaData kryptyeres med en symetric key.
-- til dette form�l oprettes keys og certifictes her.
--

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)  
BEGIN
    CREATE MASTER KEY ENCRYPTION BY   
    PASSWORD = '23987hxJKL95QYV4369#ghf0%lekjg5k3fd117r$$#1946kcj$n44ncjhdlj'  
END
GO  

CREATE CERTIFICATE TemaDBCert  
   WITH SUBJECT = 'Password for Temadata source';  
GO  

CREATE SYMMETRIC KEY SourcePwd_Key
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE TemaDBCert;  
GO  