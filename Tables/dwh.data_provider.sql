CREATE TABLE [dwh].[data_provider]
(
[provider_key] [int] NOT NULL IDENTITY(1, 1),
[provider_id] [uniqueidentifier] NOT NULL,
[provider_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssn] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_loc_id] [uniqueidentifier] NULL,
[degree] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middle_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
