-- ==========================================================================
-- Author                 : RUA, Sweco
-- Create date            : 2019-06-13 
-- Updated                : $Date: 2019-12-29 00:15:22 +0100 (sø, 29 dec 2019) $
-- Updated by             : $Author: admtmi $
-- Description            : Create temadatabase
-- ==========================================================================
DECLARE @svn_revision	varchar(15)	= '$Rev: 31 $'
DECLARE @db_version		varchar(15)	= '1.0'
DECLARE @scriptnavn		varchar(60)	= '001 Create TemaDB'
DECLARE @beskrivelse	varchar(250)= 'Create temadatabase'


-------------------------------------------------------------------------------------------------------------------------
USE [master]
GO

--DROP DATABASE [TemaDB]
--GO

CREATE DATABASE [TemaDB]
GO

ALTER DATABASE [TemaDB] SET COMPATIBILITY_LEVEL = 120
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TemaDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [TemaDB] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [TemaDB] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [TemaDB] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [TemaDB] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [TemaDB] SET ARITHABORT OFF 
GO

ALTER DATABASE [TemaDB] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [TemaDB] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [TemaDB] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [TemaDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [TemaDB] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [TemaDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [TemaDB] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [TemaDB] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [TemaDB] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [TemaDB] SET  DISABLE_BROKER 
GO

ALTER DATABASE [TemaDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [TemaDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [TemaDB] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [TemaDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [TemaDB] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [TemaDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [TemaDB] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [TemaDB] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [TemaDB] SET  MULTI_USER 
GO

ALTER DATABASE [TemaDB] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [TemaDB] SET DB_CHAINING OFF 
GO

--ALTER DATABASE [TemaDB] SET DEFAULT_FULLTEXT_LANGUAGE = 1033 
--GO

--ALTER DATABASE [TemaDB] SET DEFAULT_LANGUAGE = 1033 
--GO

--ALTER DATABASE [TemaDB] SET NESTED_TRIGGERS = ON 
--GO

--ALTER DATABASE [TemaDB] SET TRANSFORM_NOISE_WORDS = OFF 
--GO

--ALTER DATABASE [TemaDB] SET TWO_DIGIT_YEAR_CUTOFF = 2049 
--GO

ALTER DATABASE [TemaDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [TemaDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

--ALTER DATABASE [TemaDB] SET DELAYED_DURABILITY = DISABLED 
--GO

--ALTER DATABASE [TemaDB] SET QUERY_STORE = OFF
--GO

-------------------------------------------------------------------------------------------------------------------------
--USE [TemaDB]
--GO

--ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
--GO

--ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
--GO

--ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
--GO

--ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
--GO


-------------------------------------------------------------------------------------------------------------------------
USE [master]
GO

ALTER DATABASE [TemaDB] SET  READ_WRITE 
GO


-------------------------------------------------------------------------------------------------------------------------
USE [TemaDB]
GO

create schema RIT
go

create schema PROD
go

create schema TEMP
go


