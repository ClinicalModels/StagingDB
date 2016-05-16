CREATE TABLE [dbo].[staging_ng_eligibility_files_data]
(
[seq_no] [int] NOT NULL IDENTITY(1, 1),
[txt_chc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_effdate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_termdate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_patid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_plan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_subssn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_lastnm] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_firstnm] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_street] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_dob] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_sex] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_language] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_mcal10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_otherid2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_site] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_membid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_hic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_mcarea] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_mcareb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_ccs] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_ccsdt] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_cob] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_hfpcopay] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_ac] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_transactionCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_transactionDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_sourcefile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[staging_ng_eligibility_files_data] ADD CONSTRAINT [PK__staging___4B660EB1A9D5A2A2] PRIMARY KEY CLUSTERED  ([seq_no]) ON [PRIMARY]
GO
