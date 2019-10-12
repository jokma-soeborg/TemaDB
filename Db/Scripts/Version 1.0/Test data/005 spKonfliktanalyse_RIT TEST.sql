USE TemaDB
go

-----------------------------------------------------------------------------------
-- TEST spKonfliktanalyse_RIT



delete from RIT.AnalyseInputGeometrier
--declare @wkt varchar(1000) = 'POLYGON((570165.4 6164566,569858.2 6155350,609077.4 6155042.8,607746.2 6164770.8,570165.4 6164566))'
declare @wkt varchar(1000) = 'POLYGON ((551642 6130931, 551642 6130518, 552193 6130518, 552193 6130931, 551642 6130931))'
declare @geom geometry
declare @MapExtentWkt_Konflikt varchar(100)
declare @MapExtentWkt_Interesse varchar(100)
declare @analyse_id uniqueidentifier = newid()
select @geom = geometry::STGeomFromText(@wkt,25832);

--select tema, tabelnavn from prod.TemaMetaData where isvalid=1 order by tema
insert into RIT.AnalyseInputGeometrier (AnalyseID,geom) values (@analyse_id, @geom)

--insert into ##AnalyseGeometrier (AnalyseID,TemaTabelNavn,BestemKommune,geom,buffersize,analysetype) 
--SELECT @id,'e_gis_osdd',1,@geom,100,'Konflikt'

DECLARE	@AntalResultater	INT
DECLARE	@FejlKode			INT
DECLARE	@FejlTekst			NVARCHAR(500)	
DECLARE	@CopyrightMeddelelse	NVARCHAR(250)	
--DECLARE @TemaVersion		NVARCHAR(100)
DECLARE @TemaOpdateretDato		DATETIME		
DECLARE @TemaNaesteOpdatering	DATETIME		
DECLARE @MapExtentWktKonflikt		NVARCHAR(100)
DECLARE @MapExtentWktInteresse		NVARCHAR(100)

--exec dbo.spKonfliktanalyse_RIT @analyse_id, 'Natura 2000', 'e_gis_natura2000',400,1000,1,@AntalResultater OUTPUT,@FejlKode OUTPUT, @FejlTekst OUTPUT
--exec dbo.spKonfliktanalyse_RIT @analyse_id, 'Kirkebyggelinjer', 'kirkebyggelinjer',100,null,1,@AntalResultater OUTPUT,@FejlKode OUTPUT, @FejlTekst OUTPUT
--exec dbo.spKonfliktanalyse_RIT @analyse_id, 'Fulgebeskyttelsesområder', 'fugle_bes_omr',100,2000,1,@AntalResultater OUTPUT, @TemaVersion OUTPUT,@MapExtentWkt_Konflikt OUTPUT,@MapExtentWkt_Interesse OUTPUT, @FejlKode OUTPUT, @FejlTekst OUTPUT
-- soe_bes_linjer	Søbeskyttelsesområder

exec RIT.spKonfliktanalyse_RIT 
	@analyse_id, 
	'Beskyttede Sten og jorddiger',	-- temanavn
	'bes_sten_jorddiger',			-- tematabelnavn
	150,						-- konfliktbuffer
	NULL,						-- interesebuffer
	1,							-- bestem kommune
	@AntalResultater OUTPUT,
	@TemaOpdateretDato OUTPUT,
	@TemaNaesteOpdatering OUTPUT,
	@CopyrightMeddelelse OUTPUT,
	@MapExtentWktKonflikt OUTPUT,
	@MapExtentWktInteresse OUTPUT,
	@FejlKode OUTPUT, 
	@FejlTekst OUTPUT




select	@AntalResultater as [@AntalResultater], 
		@TemaOpdateretDato as [@TemaOpdateretDato], 
		@CopyrightMeddelelse as [@CopyrightMeddelelse],
		@TemaNaesteOpdatering as [@TemaNaesteOpdatering],
		@FejlKode as [@FejlKode], 
		@FejlTekst as [@FejlTekst], 
		@MapExtentWktKonflikt as MapExtentWktKonflikt, 
		@MapExtentWktInteresse as MapExtentWktInteresse
select * 
from rit.AnalyseResultat 
where ANALYSEID=@analyse_id



SELECT 'Input geom' as Label, geom FROM rit.AnalyseInputGeometrier WHERE ANALYSEID=@analyse_id
UNION ALL
select 'Map Extent Konflikt' as label, geometry::STGeomFromText(@MapExtentWktKonflikt,25832) as geom
UNION ALL
select 'Map Extent Interesse' as label, geometry::STGeomFromText(@MapExtentWktInteresse,25832) as geom
UNION ALL
select 'Temaobjekt' as Label, TemaGeom as Geom  from rit.AnalyseResultat where ANALYSEID=@analyse_id
--union all
--select '['+cast(kommunekode as char(3))+'] '+k.SHORTNAME as Label, k.Geom as Geom  from prod.kommune k where KOMMUNEKODE between 401 and 499
--select '['+cast(komkode as char(3))+'] '+k.komnavn as Label, k.Geom as Geom  from prod.kommune k where KOMkode between 401 and 499



