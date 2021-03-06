--use JAR_RSyd_Drift_20190118
use TemaDB
go

-----------------------------------------------------------------------------
SELECT * 
INTO PROD.e_gis_overfladevand
FROM [JAR_RSyd_Drift_20190118].[dbo].[e_gis_overfladevand]

--select top 10 * from e_gis_overfladevand

alter table PROD.e_gis_overfladevand add primary key (pkid)
GO


DROP INDEX IF EXISTS [IX_e_gis_overfladevand_spatial] ON PROD.[e_gis_overfladevand]
GO

CREATE SPATIAL INDEX [IX_e_gis_overfladevand_spatial] ON PROD.[e_gis_overfladevand]
(
	[geom]
)USING  GEOMETRY_GRID 
WITH (BOUNDING_BOX =(400000, 5910000, 912000, 6422000), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

-----------------------------------------------------------------------------
SELECT * 
INTO PROD.e_gis_osd
FROM [JAR_RSyd_Drift_20190118].[dbo].[e_gis_osd]

--select top 10 * from e_gis_osd

alter table PROD.e_gis_osd add primary key (pkid)
GO


DROP INDEX IF EXISTS [IX_e_gis_osd_spatial] ON PROD.[e_gis_osd]
GO

CREATE SPATIAL INDEX [IX_e_gis_osd_spatial] ON PROD.[e_gis_osd]
(
	[geom]
)USING  GEOMETRY_GRID 
WITH (BOUNDING_BOX =(400000, 5910000, 912000, 6422000), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
-----------------------------------------------------------------------------
SELECT * 
INTO PROD.e_gis_natura2000
FROM [JAR_RSyd_Drift_20190118].[dbo].[e_gis_natura2000]

--select top 10 * from e_gis_natura2000

alter table PROD.e_gis_natura2000 add primary key (pkid)
GO


DROP INDEX IF EXISTS [IX_e_gis_natura2000_spatial] ON PROD.[e_gis_natura2000]
GO

CREATE SPATIAL INDEX [IX_e_gis_natura2000_spatial] ON PROD.[e_gis_natura2000]
(
	[geom]
)USING  GEOMETRY_GRID 
WITH (BOUNDING_BOX =(400000, 5910000, 912000, 6422000), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO


-----------------------------------------------------------------------------
SELECT * 
INTO PROD.e_gis_vandvaerksoplande
FROM [JAR_RSyd_Drift_20190118].[dbo].[e_gis_vandvaerksoplande]
GO

--select top 10 * from e_gis_vandvaerksoplande

alter table PROD.e_gis_vandvaerksoplande add primary key (pkid)
GO

DROP INDEX IF EXISTS [IX_e_gis_vandvaerksoplande_spatial] ON PROD.[e_gis_vandvaerksoplande]
GO

CREATE SPATIAL INDEX [IX_e_gis_vandvaerksoplande_spatial] ON PROD.[e_gis_vandvaerksoplande]
(
	[geom]
)USING  GEOMETRY_GRID 
WITH (BOUNDING_BOX =(400000, 5910000, 912000, 6422000), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO


-----------------------------------------------------------------------------
delete from PROD.Kommune;
INSERT INTO PROD.kommune (KOMMUNEKODE,SHORTNAME,LONGNAME,GEOM)
SELECT KOMMUNEKODE,SHORTNAME,LONGNAME,GEOM
FROM Raastof_udv.[dbo].kommune
where KommuneKode>0
GO



DROP INDEX IF EXISTS [IX_kommune_spatial] ON PROD.kommune
GO

CREATE SPATIAL INDEX [IX_kommune_spatial] ON PROD.kommune
(
	[geom]
)USING  GEOMETRY_GRID 
WITH (BOUNDING_BOX =(400000, 5910000, 912000, 6422000), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO