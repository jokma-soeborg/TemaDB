-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-05-28
-- Updated                : $Date: 2019-09-02 14:22:38 +0200 (ma, 02 sep 2019) $
-- Updated by             : $Author: rua $
-- Description            : Stored procedure spKonfliktanalyse_RIT
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 1953 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '005 spKonfliktanalyse_RIT.sql'
DECLARE @beskrivelse	varchar(250)= 'Stored procedure spKonfliktanalyse_RIT'


--USE Raastof_Temadata
--go

INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

-- Konfliktanalyse i temadatabasen

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--DROP PROCEDURE IF EXISTS RIT.spKonfliktanalyse_RIT;
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='RIT'
		  AND p.Name = 'spKonfliktanalyse_RIT')
BEGIN
    DROP PROCEDURE RIT.spKonfliktanalyse_RIT
END
go


CREATE PROCEDURE RIT.spKonfliktanalyse_RIT
	@AnalyseID			UNIQUEIDENTIFIER,
	@TemaNavn			NVARCHAR(100),
	@TemaTabelNavn		NVARCHAR(100),
	@KonfliktBuffer		INT,
	@InteresseBuffer	INT,
	@BestemKommune		BIT,
	-- Desuden skal der være input geometrier i tabellen ANALYSEINPUTGEOMETRIER

	@AntalResultater		INT				OUTPUT,
	@TemaOpdateretDato		DATETIME		OUTPUT,
	@TemaNaesteOpdatering	DATETIME		OUTPUT,
	@CopyRightMeddelelse    NVARCHAR(250)   OUTPUT,
	@MapExtentWktKonflikt	NVARCHAR(100)	OUTPUT,
	@MapExtentWktInteresse	NVARCHAR(100)	OUTPUT,
	@FejlKode				INT				OUTPUT, 
	@FejlTekst				NVARCHAR(500)	OUTPUT
	-- Desuden findes der output resultatrækker i tabellen ANALYSERESULTAT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	DECLARE @sql		nvarchar(4000)
	DECLARE @errmsg		nvarchar(500)
	DECLARE @errcode	INT = -3
	DECLARE @count		INT
	DECLARE @MapExtent	GEOMETRY


	BEGIN TRY
		
		----------------------------------------------------------------
		-- Check input data - AnalyseID
		SELECT @errcode = 1
		SELECT @count = COUNT(1) FROM RIT.AnalyseInputGeometrier WHERE AnalyseID=@AnalyseID AND geom IS NOT NULL;
		IF (@AnalyseID IS NULL)
			RAISERROR ('Der skal være angivet et AnalyseID', 16, 1);

		----------------------------------------------------------------
		-- Check input data - Check om Input geometrier er valide
		SELECT @errcode = 2
		IF EXISTS (SELECT 1 FROM RIT.AnalyseInputGeometrier WHERE AnalyseID=@AnalyseID AND geom IS NOT NULL AND geom.STIsValid()=0)
			RAISERROR ('Analysegeometrier er ikke valide', 16, 1);

		----------------------------------------------------------------
		-- Check input data - Check om Input geometrier er i projektionen 25832
		SELECT @errcode = 3
		IF EXISTS (SELECT 1 FROM RIT.AnalyseInputGeometrier WHERE AnalyseID=@AnalyseID AND geom IS NOT NULL AND geom.STSrid<>25832)
			RAISERROR ('Analysegeometrier er ikke i den korrekte projektion', 16, 1);

		----------------------------------------------------------------
		-- Check input data - Check om kommune geometrier er i projektionen 25832
		SELECT @errcode = 3
		IF (@BestemKommune=1)
			IF EXISTS (SELECT 1 FROM PROD.kommune WHERE geom IS NOT NULL AND geom.STSrid<>25832)
				RAISERROR ('Kommunegeometrier er ikke i den korrekte projektion', 16, 1);

		----------------------------------------------------------------
		-- Check om AnalyseID allerde er brugt
		SELECT @errcode = 4

		SELECT @errmsg = 'AnalyseID er allerede benyttet.'
		IF EXISTS (	SELECT 1 FROM RIT.AnalyseResultat WHERE ANALYSEID = @AnalyseID )
			RAISERROR (@errmsg, 16, 1);
		IF EXISTS (	SELECT 1 FROM RIT.AnalyseGeom WHERE ANALYSEID = @AnalyseID)
			RAISERROR (@errmsg, 16, 1);	

		----------------------------------------------------------------
		-- Check input data
		SELECT @errcode = 5
		SELECT @count = COUNT(1) FROM RIT.AnalyseInputGeometrier WHERE AnalyseID=@AnalyseID AND geom IS NOT NULL;
		IF (@count=0)
			RAISERROR ('Der er ikke angivet nogen analysegeometrier', 16, 1);

		----------------------------------------------------------------
		-- Check konfiguration (tematabelnavn)
		SELECT @errcode = 6
		SELECT @errmsg = 'Konfigurationsfejl. TemaMetaData indeholder ikke data for tabellen '+ISNULL('"'+@TemaTabelNavn+'"', 'NULL');
		IF NOT EXISTS (	SELECT 1 FROM PROD.TemaMetaData WHERE TabelNavn = @TemaTabelNavn	AND ISNULL(GeomKolonneNavn,'')<>'')
			RAISERROR (@errmsg, 16, 1);

		----------------------------------------------------------------
		-- Check konfiguration (valid?)
		SELECT @errcode = 7
		SELECT @errmsg = 'Temadata er ikke valide for '+ISNULL('"'+@TemaTabelNavn+'"', 'NULL');
		IF NOT EXISTS (	SELECT 1 FROM PROD.TemaMetaData WHERE TabelNavn = @TemaTabelNavn	AND ISVALID=1)
			RAISERROR (@errmsg, 16, 1);
		

		----------------------------------------------------------------
		-- Beregn Map extent
		SELECT @MapExtentWktKonflikt = NULL, @MapExtentWktInteresse = NULL;

		EXEC RIT.spGetMapExtent_RIT @AnalyseID, @KonfliktBuffer, @MapExtent OUTPUT
		IF (@MapExtent IS NOT NULL)
			SELECT @MapExtentWktKonflikt = @MapExtent.STAsText();

		SELECT @MapExtent = NULL
		IF (@InteresseBuffer IS NOT NULL)
		BEGIN
			EXEC RIT.spGetMapExtent_RIT @AnalyseID, @InteresseBuffer, @MapExtent OUTPUT
			IF (@MapExtent IS NOT NULL)
				SELECT @MapExtentWktInteresse = @MapExtent.STAsText();
		END


		----------------------------------------------------------------
		-- dan mellemregningstabel der benyttes ved selve analysen
		SELECT @errcode = 7
		INSERT INTO AnalyseGeom ( AnalyseID, TemaTabelNavn, BestemKommune, GeomOriginal, GeomBuffered, Buffersize, AnalyseType)
		SELECT
			@AnalyseID, @TemaTabelNavn, @BestemKommune,
			geom, -- Original Geometri (den der benyttes til at beregne afstand)
			case when ISNULL(@KonfliktBuffer,0)=0 then geom else geom.STBuffer(@KonfliktBuffer) end, -- Buffered Geometri (den der benyttes til overlapsanalysen)
			@KonfliktBuffer, 'Konflikt' as analysetype
		FROM RIT.AnalyseInputGeometrier 
		WHERE AnalyseID=@AnalyseID

		IF (@InteresseBuffer IS NOT NULL)
		BEGIN
			INSERT INTO AnalyseGeom ( AnalyseID, TemaTabelNavn, BestemKommune, GeomOriginal, GeomBuffered, Buffersize, AnalyseType)
			SELECT
				@AnalyseID, @TemaTabelNavn, @BestemKommune,
				geom, -- Original Geometri (den der benyttes til at beregne afstand)
				case when ISNULL(@InteresseBuffer,0)=0 then geom else geom.STBuffer(@InteresseBuffer) end, -- Buffered Geometri (den der benyttes til overlapsanalysen)
				@InteresseBuffer, 'Interesse' as analysetype
			FROM RIT.AnalyseInputGeometrier 
			WHERE AnalyseID=@AnalyseID
		END

		--select * from AnalyseGeom

		----------------------------------------------------------------
		-- Find dato hvor temaet sidst blev opdateret
		SELECT @TemaOpdateretDato = OPDATERETDATO,
		       @TemaNaesteOpdatering = FORVENTETOPDATERING,
			   @CopyRightMeddelelse = COPYRIGHTBESKED
		FROM PROD.TemaMetaData WHERE TabelNavn = @TemaTabelNavn
		
		----------------------------------------------------------------
		-- Lav analyse
		SELECT @errcode = 10

		SELECT @sql =
			'SELECT t.['+m.IdKolonneNavn +'] as TemaGeomId, '+
			''''+CAST(@AnalyseID as varchar(36))+''', ' +
			''''+@TemaNavn +''' as TemaNavn, '+
			't.['+m.GeomKolonneNavn +'] as geom, '+
			'''' + @TemaTabelNavn +''' as TemaTabelNavn, ' + 
			ISNULL(' t.['+m.tekstkolonneNavn+']','NULL') + ' as tekst, '+
			'g.analysetype, '+
			'g.buffersize, '+
			't.geom.STDistance(g.geomOriginal) as AfstandTilOrg, '+
			't.geom.STIntersects(g.geomOriginal) as InterSectsOrg, '+
			'0 as FejlKode, '+
			'NULL as FejlTekst, '+
			''''+CONVERT(VARCHAR(8),m.OPDATERETDATO,112)+''' as TemaOpdateretDato,'+
			''''+CONVERT(VARCHAR(8),m.FORVENTETOPDATERING,112)+''' as TemaNaesteOpdatering,'+
			'GETDATE() as Tidspunkt ' +
			'FROM PROD.'+TabelNavn + ' t '+
			'INNER JOIN RIT.AnalyseGeom g ON t.['+GeomKolonneNavn +'].STIntersects(g.geomBuffered)=1 AND g.AnalyseID='''+CAST(@AnalyseID AS varchar(36))+''';'
		FROM PROD.TemaMetaData m
		WHERE m.TabelNavn = @TemaTabelNavn
			
		--select @sql
		--select * from PROD.TemaMetaData

		SELECT @errcode = 11

		INSERT INTO RIT.AnalyseResultat (TemaGeomId,AnalyseId,TemaNavn,TemaGeom,TemaTabelNavn,TemaTekst,AnalyseType,AnvendtBuffer,AfstandTilOrg,InterSectsOrg,FejlKode,FejlTekst,TemaOpdateretDato,TemaNaesteOpdatering,Tidspunkt)  
		EXEC (@sql)	


		SELECT @errcode = 12

		-- fjern dubletter af konflikttypen 'interesse' såfremt de allerede findes som konflikttypen 'konflikt'
		delete from RIT.AnalyseResultat
		where AnalyseID=@AnalyseID
		AND   AnalyseType='Interesse'
		and exists (select 1 from ANALYSERESULTAT r2 
					where r2.AnalyseID=@AnalyseID 
					and r2.AnalyseType='Konflikt' 
					and r2.TemaGeomId=ANALYSERESULTAT.TemaGeomId);
		----------------------------------------------------------------
		-- Bestem Kommune

		--SELECT * FROM ANALYSERESULTAT WHERE AnalyseID = @AnalyseID;

		IF (@BestemKommune = 1)
		BEGIN
			SELECT @errcode = 20

			-- drop table if exists #tmp ;
			IF OBJECT_ID('tempdb..#tmp') IS NOT NULL 
			BEGIN 
				DROP TABLE #tmp
			END

			

			-- Find kommuner (der kan være flere pr. temageometri)
			SELECT r.id, cast(k.Komkode as int) as kommunekode
			INTO #tmp
			FROM RIT.AnalyseResultat r
			inner join RIT.AnalyseGeom ag on ag.ANALYSEID=r.ANALYSEID
			INNER JOIN PROD.Kommune k on r.TEMAGEOM.STIntersection(ag.GEOMBUFFERED).STIntersects(k.GEOM)=1  -- ON k.geom.STIntersects(r.TemaGeom)=1
			WHERE r.ANALYSEID=@AnalyseID


			--select * from #tmp

			SELECT @errcode = 21

			-- Opdater kommunerkoder som kommasepareret liste i resultatet
			UPDATE RIT.AnalyseResultat
			SET KommuneKode = x.KommuneKodeListe
			FROM (
				select distinct id ,
				STUFF((	Select ','+cast(KommuneKode as varchar)
						from #tmp T1
						where T1.id=T2.id
						FOR XML PATH(''))
						,1,1,'') as KommuneKodeListe from #tmp T2
			) x
			WHERE x.id = RIT.AnalyseResultat.id
			AND RIT.AnalyseResultat.ANALYSEID =@AnalyseID
		END

		-- Sæt output parameter værdier
		SELECT	@AntalResultater = COUNT(1),
				@FejlKode=0, 
				@FejlTekst=NULL
		FROM RIT.AnalyseResultat 
		WHERE AnalyseID = @AnalyseID

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000); 
		SELECT  @ErrorMessage = ERROR_MESSAGE();
		-- Sæt output parameter værdier
		SELECT @AntalResultater = 0, @FejlKode=@errcode, @FejlTekst=@ErrorMessage

		INSERT INTO ANALYSERESULTAT ( AnalyseId, TemaNavn, TemaTabelNavn, FejlKode, FejlTekst, Tidspunkt) SELECT @AnalyseId, @TemaNavn, @TemaTabelNavn, @errcode, @ErrorMessage, GETDATE()
	END CATCH

	-- Oprydning
	DELETE FROM RIT.AnalyseInputGeometrier WHERE AnalyseID = @AnalyseID;
	DELETE FROM RIT.AnalyseGeom WHERE AnalyseID = @AnalyseID;
	
END
GO



