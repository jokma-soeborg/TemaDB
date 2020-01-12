-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-05-28
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Create tabeller for temadatabase
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '002 Create TemaDB tables.sql'
DECLARE @beskrivelse	varchar(250)= 'Create tabeller for temadatabase'


/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     21-06-2019 15:33:40                          */
/*==============================================================*/



if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('PROD.OPDATERINGSLOG') and o.name = 'FK_OPDATERI_REF_OPDAT_TEMAMETA')
alter table PROD.OPDATERINGSLOG
   drop constraint FK_OPDATERI_REF_OPDAT_TEMAMETA
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('RIT.ANALYSEGEOM')
            and   name  = 'ANALYSE_IDX'
            and   indid > 0
            and   indid < 255)
   drop index RIT.ANALYSEGEOM.ANALYSE_IDX
go

if exists (select 1
            from  sysobjects
           where  id = object_id('RIT.ANALYSEGEOM')
            and   type = 'U')
   drop table RIT.ANALYSEGEOM
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('RIT.ANALYSEINPUTGEOMETRIER')
            and   name  = 'ANALYSE_IDX'
            and   indid > 0
            and   indid < 255)
   drop index RIT.ANALYSEINPUTGEOMETRIER.ANALYSE_IDX
go

if exists (select 1
            from  sysobjects
           where  id = object_id('RIT.ANALYSEINPUTGEOMETRIER')
            and   type = 'U')
   drop table RIT.ANALYSEINPUTGEOMETRIER
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('RIT.ANALYSERESULTAT')
            and   name  = 'ANALYSEIDX'
            and   indid > 0
            and   indid < 255)
   drop index RIT.ANALYSERESULTAT.ANALYSEIDX
go

if exists (select 1
            from  sysobjects
           where  id = object_id('RIT.ANALYSERESULTAT')
            and   type = 'U')
   drop table RIT.ANALYSERESULTAT
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PROD.KOMMUNE')
            and   type = 'U')
   drop table PROD.KOMMUNE
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('PROD.OPDATERINGSLOG')
            and   name  = 'TEMAMETADATAIDX'
            and   indid > 0
            and   indid < 255)
   drop index PROD.OPDATERINGSLOG.TEMAMETADATAIDX
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PROD.OPDATERINGSLOG')
            and   type = 'U')
   drop table PROD.OPDATERINGSLOG
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DBO.SCRIPT_LOG')
            and   type = 'U')
   drop table DBO.SCRIPT_LOG
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('PROD.TEMAMETADATA')
            and   name  = 'TABELNAVN_IDX'
            and   indid > 0
            and   indid < 255)
   drop index PROD.TEMAMETADATA.TABELNAVN_IDX
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PROD.TEMAMETADATA')
            and   type = 'U')
   drop table PROD.TEMAMETADATA
go





/*==============================================================*/
/* Table: ANALYSEGEOM                                           */
/*==============================================================*/
create table RIT.AnalyseGeom (
   ID                   int                  identity,
   ANALYSEID            uniqueidentifier     not null,
   TEMATABELNAVN        varchar(100)         not null,
   BESTEMKOMMUNE        bit                  not null,
   GEOMORIGINAL         geometry             not null,
   GEOMBUFFERED         geometry             not null,
   BUFFERSIZE           int                  null,
   ANALYSETYPE          varchar(20)          not null,
   constraint PK_ANALYSEGEOM primary key (ID)
)
go

/*==============================================================*/
/* Index: ANALYSE_IDX                                           */
/*==============================================================*/
create index ANALYSE_IDX on RIT.ANALYSEGEOM (
ANALYSEID ASC
)
go

/*==============================================================*/
/* Table: ANALYSEINPUTGEOMETRIER                                */
/*==============================================================*/
create table RIT.AnalyseInputGeometrier (
   ID                   int                  identity,
   ANALYSEID            uniqueidentifier     not null,
   GEOM                 geometry             null,
   constraint PK_ANALYSEINPUTGEOMETRIER primary key (ID)
)
go

/*==============================================================*/
/* Index: ANALYSE_IDX                                           */
/*==============================================================*/
create index ANALYSE_IDX on RIT.ANALYSEINPUTGEOMETRIER (
ANALYSEID ASC
)
go

/*==============================================================*/
/* Table: ANALYSERESULTAT                                       */
/*==============================================================*/
create table RIT.AnalyseResultat (
   ID                   int                  identity,
   TEMAGEOMID           varchar(36)          null,
   ANALYSEID            uniqueidentifier     not null,
   TEMANAVN             varchar(100)         null,
   TEMATABELNAVN        varchar(100)         not null,
   TEMAGEOM             geometry             null,
   TEMATEKST            varchar(1000)        null,
   ANALYSETYPE          varchar(20)          null,
   ANVENDTBUFFER        INT                  null,
   AFSTANDTILORG        float                null,
   INTERSECTSORG        bit                  null,
   KOMMUNEKODE          varchar(1000)        null,
   FEJLKODE             int                  not null,
   FEJLTEKST            varchar(1000)        null,
   TEMAOPDATERETDATO    datetime             null,
   TEMANAESTEOPDATERING datetime             null,
   TIDSPUNKT            datetime             not null,
   constraint PK_ANALYSERESULTAT primary key (ID)
)
go

/*==============================================================*/
/* Index: ANALYSEIDX                                            */
/*==============================================================*/
create index ANALYSEIDX on RIT.ANALYSERESULTAT (
ANALYSEID ASC
)
go

/*==============================================================*/
/* Table: KOMMUNE                                               */
/*==============================================================*/
--create table PROD.Kommune (
----   KOMMUNEKODE          int                  not null,
--   KOMKODE		        int                  not null,
--   SHORTNAME            varchar(50)          not null,
--   LONGNAME             varchar(50)          not null,
--   GEOM                 geometry             not null,
--   constraint PK_KOMMUNE primary key (KOMKODE)
--)
--go
CREATE TABLE [PROD].[kommune](
	[ogr_fid] [int] IDENTITY(1,1) NOT NULL,
	[GEOM] [geometry] NULL,
	[feat_id] [numeric](11, 0) NULL,
	[feat_kode] [numeric](6, 0) NULL,
	[feat_type] [nvarchar](40) NULL,
	[feat_sttxt] [nvarchar](20) NULL,
	[geom_sttxt] [nvarchar](20) NULL,
	[dagi_id] [numeric](11, 0) NULL,
	[areal] [numeric](11, 2) NULL,
	[regionkode] [nvarchar](4) NULL,
	[regionnavn] [nvarchar](50) NULL,
	[gyldig_fra] [date] NULL,
	[gyldig_til] [date] NULL,
	[komkode] [nvarchar](4) NULL,
	[komnavn] [nvarchar](50) NULL,
	[dq_specifk] [nvarchar](60) NULL,
	[dq_statem] [nvarchar](40) NULL,
	[dq_descr] [nvarchar](40) NULL,
	[dq_process] [nvarchar](40) NULL,
	[dq_respons] [nvarchar](45) NULL,
	[dq_posacpl] [nvarchar](40) NULL,
	[dq_posaclv] [nvarchar](40) NULL,
	[timeof_cre] [date] NULL,
	[timeof_pub] [date] NULL,
	[timeof_rev] [date] NULL,
	[timeof_exp] [date] NULL,
    CONSTRAINT [PK_kommune] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
	)
GO


/*==============================================================*/
/* Table: OPDATERINGSLOG                                        */
/*==============================================================*/
create table PROD.OpdateringsLog (
   OPDATERINGSLOGID     int                  identity,
   TEMAMETADATAID       uniqueidentifier     null,
   FEJLKODE             int                  null,
   FEJLTEKST            varchar(1000)        null,
   OPDATERETAF          varchar(100)         null,
   TIDSPUNKT            datetime             not null,
   constraint PK_OPDATERINGSLOG primary key (OPDATERINGSLOGID)
)
go

/*==============================================================*/
/* Index: TEMAMETADATAIDX                                       */
/*==============================================================*/
create index TEMAMETADATAIDX on PROD.OPDATERINGSLOG (
TEMAMETADATAID ASC
)
go

/*==============================================================*/
/* Table: SCRIPT_LOG                                            */
/*==============================================================*/
create table DBO.Script_log (
   ID                   int                  identity,
   DB_VERSION           varchar(15)          null,
   DATO                 datetime             null constraint DF__Script_log__dato__7755B73D default getdate(),
   SVN_REVISION         varchar(15)          null,
   SCRIPTNAVN           varchar(60)          null,
   BESKRIVELSE          varchar(250)         null,
   constraint PK_SCRIPT_LOG primary key (ID)
)
on "PRIMARY"
go

/*==============================================================*/
/* Table: TEMAMETADATA                                          */
/*==============================================================*/
create table PROD.TemaMetaData (
   ID                   uniqueidentifier     not null,
   GRUPPE               varchar(100)         not null,
   TEMA                 varchar(100)         not null,
   BESKRIVELSE          varchar(1000)        null,
   AUTOOPDATERINGAKTIV  bit                  not null constraint CHK_AUTOOPDATERINGAKTIV_DEFAULT default 0,
   UDBYDER              varchar(100)         null,
   COPYRIGHTBESKED      varchar(250)         null,
   SOURCEURL            varchar(250)         null,
   SOURCEUSER           varchar(100)         null,
   SOURCEPWD            varbinary(128)       null,
   TABELNAVN            varchar(100)         not null,
   IDKOLONNENAVN        varchar(100)         not null,
   GEOMKOLONNENAVN      varchar(100)         not null,
   TEKSTKOLONNENAVN     varchar(100)         null,
   ISVALID              bit                  not null,
   OPDATERETDATO        datetime             not null,
   FORVENTETOPDATERING  AS (DATEADD(DAY,OpdateringsFrekvDage,OpdateretDato)),
   OPDATERINGSFREKVDAGE int                  not null,
   constraint PK_TEMAMETADATA primary key (ID)
)
go



/*==============================================================*/
/* Index: TABELNAVN_IDX                                         */
/*==============================================================*/
create unique index TABELNAVN_IDX on PROD.TEMAMETADATA (
TABELNAVN ASC
)
WHERE ISVALID=1
go

alter table PROD.OPDATERINGSLOG
   add constraint FK_OPDATERI_REF_OPDAT_TEMAMETA foreign key (TEMAMETADATAID)
      references PROD.TEMAMETADATA (ID)
         on delete cascade
go


