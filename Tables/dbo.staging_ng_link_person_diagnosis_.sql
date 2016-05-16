CREATE TABLE [dbo].[staging_ng_link_person_diagnosis_]
(
[per_mon_id] [int] NOT NULL,
[Dx_id] [int] NOT NULL IDENTITY(1, 1),
[person_id] [uniqueidentifier] NOT NULL,
[seq_date] [date] NULL,
[Diag_Full_Name] [varchar] (268) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[diagnosis_code_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_id] [uniqueidentifier] NULL,
[provider_id] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
