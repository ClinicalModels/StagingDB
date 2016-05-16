CREATE TABLE [fds].[dim_diagnosis]
(
[diag_full_name] [varchar] (268) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[diagnosis_code_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICD9_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
