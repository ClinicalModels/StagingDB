CREATE TABLE [dbo].[data_provider_ecw]
(
[ecw_prov_key] [int] NOT NULL IDENTITY(1, 1),
[provider_id] [int] NOT NULL,
[location_id] [numeric] (11, 0) NULL,
[provider_last_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider_first_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[speciality] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[providerCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uemail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upaddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facility_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_nickname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeleteFlag] [tinyint] NULL
) ON [PRIMARY]
GO
