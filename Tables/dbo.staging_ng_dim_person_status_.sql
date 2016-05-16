CREATE TABLE [dbo].[staging_ng_dim_person_status_]
(
[per_mon_id] [int] NOT NULL,
[Age] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberYears] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PatientLiving] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Chronic_Pain] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Patient_Active] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
