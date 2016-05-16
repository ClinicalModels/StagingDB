CREATE TABLE [dbo].[staging_ng_data_diagnosis_]
(
[per_mon_id] [int] NOT NULL,
[seq_date] [date] NULL,
[Dx_id] [int] NOT NULL IDENTITY(1, 1),
[diagnosis_code_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICD9_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[person_id] [uniqueidentifier] NOT NULL,
[location_id] [uniqueidentifier] NULL,
[provider_id] [uniqueidentifier] NULL,
[Diag_Full_Name] [varchar] (268) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
