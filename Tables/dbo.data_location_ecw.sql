CREATE TABLE [dbo].[data_location_ecw]
(
[ecw_location_key] [int] NOT NULL IDENTITY(1, 1),
[location_id] [numeric] (10, 0) NULL,
[Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[facilitynickname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[portal_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Tel] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingAddressLine1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingAddressLine2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingCity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingState] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingTel] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FacilityType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_start_date] [datetime] NULL
) ON [PRIMARY]
GO
