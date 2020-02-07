-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-05-28
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sÃ¸, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Stored procedure spGetMapExtent_RIT
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '004 spGetMapExtent_RIT.sql'
DECLARE @beskrivelse	varchar(250)= 'Stored procedure spGetMapExtent_RIT'


--USE Raastof_Temadata
--go


INSERT INTO script_log (db_version,dato,scriptnavn,beskrivelse,svn_revision)
VALUES  (@db_version,getdate(),@scriptnavn,@beskrivelse,@svn_revision);
GO

-- Beregn map-extent til konfliktanalyse i temadatabasen

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--DROP PROCEDURE IF EXISTS RIT.spGetMapExtent_RIT;
IF EXISTS(SELECT s.name, p.* FROM sys.procedures p
          INNER JOIN sys.schemas s on s.schema_id=p.schema_id
          WHERE s.name ='RIT'
		  AND p.Name = 'spGetMapExtent_RIT')
BEGIN
    DROP PROCEDURE RIT.spGetMapExtent_RIT
END
go


CREATE PROCEDURE RIT.spGetMapExtent_RIT
	@AnalyseID	UNIQUEIDENTIFIER,
	@BUFFER		INT,
	@MapExtent	GEOMETRY OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MinX			INT
	DECLARE @MinY			INT
	DECLARE @MaxX			INT
	DECLARE @MaxY			INT
	DECLARE @N				INT
	DECLARE @Height			FLOAT
	DECLARE @Width			FLOAT
	DECLARE @ASPECTRATIO	FLOAT = 4.0/3.0; -- Opsætnings parameter (konstant 4:3)
	DECLARE @WKT			VARCHAR(500)
	DECLARE @InputGeom		GEOMETRY


	--------------------------------------------------------------------------------------------
	-- Find Envelope for geometrier bestemt ved ANALYSEID
	SELECT @InputGeom = geometry::EnvelopeAggregate(geom)
	FROM RIT.AnalyseInputGeometrier
	where ANALYSEID = @ANALYSEID

	-- For at danne en margin, gøres denne envelope lidt større
	IF (ISNULL(@BUFFER,0)=0)
		select @BUFFER = 30 -- Default på 10 meter
	
	select @InputGeom = @InputGeom.STBuffer(@BUFFER).STEnvelope()

	--select @InputGeomg

	--------------------------------------------------------------------------------------------
	-- Bestem x,y koordinater
	SELECT
		   @MinX = ROUND(@InputGeom.STPointN(1).STX,0), -- AS MinX,
		   @MinY = ROUND(@InputGeom.STPointN(1).STY,0), -- AS MinY,
		   @MaxX = ROUND(@InputGeom.STPointN(3).STX,0), -- AS MaxX,
		   @MaxY = ROUND(@InputGeom.STPointN(3).STY,0)  -- AS MaxX

	--select @Minx as MinX, @maxx as MaxX

	--------------------------------------------------------------------------------------------
	-- Beregn højde og bredde af envelope
	SELECT 
		@Height = @MaxY - @MinY, 
		@Width = @MaxX - @MinX

	--select @Height as height, @Width as width, @ASPECTRATIO as aspectratio, @Width/@Height as geom_aspectratio

	-- Beregn en større Højde eller bredde for at tilpasse til ønsket aspectratio
	-- Tilpas X eller Y i forhold til denne nye højde eller bredde.
	IF ((@Width/@Height)>@ASPECTRATIO)
	BEGIN
		SELECT @Height = ROUND(@Width/@ASPECTRATIO ,0)

		SELECT @N = (@MinY+@MaxY)/2
		SELECT @MinY = @N - (@Height/2) 
		SELECT @MaxY = @N + (@Height/2) 
		--select @Width/@Height as geom_aspectratio_korrigeret_A
	END
	ELSE
	BEGIN
		SELECT @Width = ROUND(@Height*@ASPECTRATIO ,0)

		SELECT @N = (@MinX+@MaxX)/2
		SELECT @MinX = @N - (@Width/2) 
		SELECT @MaxX = @N + (@Width/2)
		--select @Width/@Height as geom_aspectratio_korrigeret_B
	END

	--select @Height as h_ny, 	@Width as w_ny

	--------------------------------------------------------------------------------------------
	-- Dan en ny extent i med det rette aspectratio
	select @wkt = 'POLYGON (('  +cast(@minX as varchar)+' '+cast(@maxy as varchar)+', '
								+cast(@minX as varchar)+' '+cast(@miny as varchar)+', '
								+cast(@maxX as varchar)+' '+cast(@miny as varchar)+', '
								+cast(@maxX as varchar)+' '+cast(@maxy as varchar)+', '
								+cast(@minX as varchar)+' '+cast(@maxy as varchar)+'))'
	
	select @MapExtent = geometry::STGeomFromText(@wkt,25832)


END;