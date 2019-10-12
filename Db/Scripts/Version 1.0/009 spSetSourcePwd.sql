USE [TemaDB]
GO
-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-08-08
-- Updated                : $Date: 2019-08-08 13:31:38 +0200 (to, 08 aug 2019) $
-- Updated by             : $Author: rua $
-- Description            : Stored procedure spSetSourcePwd
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 1855 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '009 spSetSourcePwd.sql'
DECLARE @beskrivelse	varchar(250)= 'Stored procedure spSetSourcePwd'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--DROP PROCEDURE IF EXISTS PROD.spSetSourcePwd;
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='PROD'
		  AND p.Name = 'spSetSourcePwd')
BEGIN
    DROP PROCEDURE PROD.spSetSourcePwd
END
go

/* Krypterer password og opdaterer tabellen TemaMetaData med den krypterde værdi */
CREATE PROCEDURE PROD.spSetSourcePwd
	@TemaMetaDataID	UNIQUEIDENTIFIER,
	@pwd			VARCHAR(25)
AS
BEGIN
	-- Open the symmetric key with which to encrypt the data.  
	OPEN SYMMETRIC KEY SourcePwd_Key  
	   DECRYPTION BY CERTIFICATE TemaDBCert;  

	-- Encrypt the value of @pwd using the symmetric key SourcePwd_Key.  
	-- Save the result in table prod.TemaMetaData column sourcepwd.    

	UPDATE prod.TemaMetaData
	SET sourcepwd = EncryptByKey(
						Key_GUID('SourcePwd_Key'),   -- the GUID of the key to be used to encrypt the cleartext
						@pwd,						 -- cleartext (text to be encrypted)
						1,                           -- Indicates whether an authenticator will be encrypted together with the cleartext. Must be 1 when using an authenticator
						HashBytes('SHA1', CONVERT( varbinary  , @TemaMetaDataID) ) -- authenticator
						)
	WHERE ID = @TemaMetaDataID;					 
END
GO  


