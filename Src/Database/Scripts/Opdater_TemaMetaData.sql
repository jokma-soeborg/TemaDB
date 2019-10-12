/*
Temalag hentes fra:
http://www.miljoeportal.dk/myndighed/Arealinformation/Sider/Download-data.aspx#MyndighedArealKilde
*/

Use [TemaDb]
Go

Update [PROD].[TemaMetaData]
set 
	[AUTOOPDATERINGAKTIV]=1
	,[TEMA] = 'EF_habitatområder'
	,[GEOMKOLONNENAVN] = 'GEOM'
	,[SOURCEURL] = 'http://arealdatamapping.blob.core.windows.net/geocortex/HABITAT_OMR_MITAB.zip'
	,[TABELNAVN] = 'EUHabitatomraader'
	,[IDKOLONNENAVN] = 'ogr_fid'
	,[TEKSTKOLONNENAVN] = 'objektnavn'
	,[COPYRIGHTBESKED] = 'Indeholder data, som benyttes i henhold til vilkår for brug af danske offentlige data'
where [ID] = 'f4963a9c-6a1a-4d5c-b24b-ff25ca74e03c'
Go

Update [PROD].[TemaMetaData]
set 
	[AUTOOPDATERINGAKTIV]=1
	,[TEMA] = 'Kirkebyggelinier'
	,[GEOMKOLONNENAVN] = 'GEOM'
	,[SOURCEURL] = 'http://arealdatamapping.blob.core.windows.net/geocortex/KIRKEBYGGELINJER_SHAPE.zip'
	,[TABELNAVN] = 'Kirkebyggelinjer'
	,[IDKOLONNENAVN] = 'ogr_fid'
	,[TEKSTKOLONNENAVN] = 'cvr_navn'
	,[COPYRIGHTBESKED] = 'Indeholder data, som benyttes i henhold til vilkår for brug af danske offentlige data'
where [ID] = '430e5d6c-74a1-47c1-920f-8678641572fb'
Go

Update [PROD].[TemaMetaData]
set 
	[AUTOOPDATERINGAKTIV]=1
	,[TEMA] = 'Ramsar områder'
	,[GEOMKOLONNENAVN] = 'GEOM'
	,[SOURCEURL] = 'http://arealdatamapping.blob.core.windows.net/geocortex/RAMSAR_OMR_SHAPE.zip'
	,[TABELNAVN] = 'ramsar_omr'
	,[IDKOLONNENAVN] = 'ogr_fid'
	,[TEKSTKOLONNENAVN] = 'objektnavn'
	,[COPYRIGHTBESKED] = 'Indeholder data, som benyttes i henhold til vilkår for brug af danske offentlige data'
where [ID] = '16AED897-4F34-46B5-99E8-A997C0AEECA9'
Go

Update [PROD].[TemaMetaData]
set 
	[AUTOOPDATERINGAKTIV]=1
	,[TEMA] = 'Søbeskyttelseslinier'
	,[GEOMKOLONNENAVN] = 'GEOM'
	,[SOURCEURL] = 'http://arealdatamapping.blob.core.windows.net/geocortex/SOE_BES_LINJER_SHAPE.zip'
	,[TABELNAVN] = 'soe_bes_linjer'
	,[IDKOLONNENAVN] = 'ogr_fid'
	,[TEKSTKOLONNENAVN] = 'cvr_navn'
	,[COPYRIGHTBESKED] = 'Indeholder data, som benyttes i henhold til vilkår for brug af danske offentlige data'
where [ID] = '8AC6787C-EBDE-41C1-9915-94079EAD5950'
Go

Update [PROD].[TemaMetaData]
set 
	[AUTOOPDATERINGAKTIV]=1
	,[TEMA] = 'EF fuglebeskyttelsesområder'
	,[GEOMKOLONNENAVN] = 'GEOM'
	,[SOURCEURL] = 'http://arealdatamapping.blob.core.windows.net/geocortex/FUGLE_BES_OMR_SHAPE.zip'
	,[TABELNAVN] = 'fugle_bes_omr'
	,[IDKOLONNENAVN] = 'ogr_fid'
	,[TEKSTKOLONNENAVN] = 'objektnavn'
	,[COPYRIGHTBESKED] = 'Indeholder data, som benyttes i henhold til vilkår for brug af danske offentlige data'
where [ID] = '80B5820C-3C4A-4243-9168-2FEE4E7A15E1'
Go

