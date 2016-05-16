CREATE TABLE [dbo].[data_diagnosis_ecw]
(
[person_id_ecw] [int] NOT NULL,
[encounter_id_ecw] [int] NULL,
[icd_code] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diagnosis_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[start_date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chronic_dx_label] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icd_code_trimmed] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_enc] [varchar] (511) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_enc_rank] [bigint] NULL
) ON [PRIMARY]
GO
