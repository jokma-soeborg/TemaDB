USE [TemaDB]
GO
-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-08-08
-- Updated                : $Date: 2019-08-08 13:35:46 +0200 (to, 08 aug 2019) $
-- Updated by             : $Author: rua $
-- Description            : Stored procedure spDecryptPwd
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 1856 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '010 spGetSourcePwd.sql'
DECLARE @beskrivelse	varchar(250)= 'Stored procedure spGetSourcePwd'


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO


--DROP PROCEDURE IF EXISTS PROD.spGetSourcePwd;
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='PROD'
		  AND p.Name = 'spGetSourcePwd')
BEGIN
    DROP PROCEDURE PROD.spGetSourcePwd
END
go

/* Krypterer password og opdaterer tabellen TemaMetaData med den krypterde værdi */
CREATE PROCEDURE PROD.spGetSourcePwd
	@TemaMetaDataID	UNIQUEIDENTIFIER,
	@pwd			VARCHAR(25)			OUTPUT
AS
BEGIN

	-- Open the symmetric key with which to decrypt the data.  
	OPEN SYMMETRIC KEY SourcePwd_Key  
	   DECRYPTION BY CERTIFICATE TemaDBCert;  

  
	-- Decrypt
	SELECT @PWD = CONVERT(varchar, 
	                      DecryptByKey(sourcepwd, -- the decryptet data "ciphertext"
                                       1,         -- indicates whether the original encryption process included, and encrypted,
                                       HashBytes('SHA1', CONVERT(varbinary, ID) ) -- authenticator
                                      )
                         )
	FROM prod.TEMAMETADATA
	WHERE ID = @TemaMetaDataID

END
GO  

