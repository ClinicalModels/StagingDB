CREATE TABLE [fds].[dim_encounter_status]
(
[EncStatusKey] [bigint] NULL,
[enc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billable_enc_ct] [int] NOT NULL,
[qual_enc_ct] [int] NOT NULL,
[Encounter_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Billable_ind] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qual_ind] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
