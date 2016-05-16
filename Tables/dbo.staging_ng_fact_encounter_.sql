CREATE TABLE [dbo].[staging_ng_fact_encounter_]
(
[EncStatusKey] [bigint] NULL,
[per_mon_id] [int] NULL,
[enc_id] [uniqueidentifier] NOT NULL,
[location_id] [uniqueidentifier] NULL,
[provider_id] [uniqueidentifier] NULL,
[person_id] [uniqueidentifier] NOT NULL,
[created_by] [int] NOT NULL,
[enc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enc_cr_date] [date] NULL,
[Enc_md_date] [date] NULL,
[enc_bill_date] [date] NULL,
[first_mon_date] [date] NULL,
[billable_enc_ct] [int] NOT NULL,
[qual_enc_ct] [int] NOT NULL,
[enc_count] [int] NOT NULL
) ON [PRIMARY]
GO
