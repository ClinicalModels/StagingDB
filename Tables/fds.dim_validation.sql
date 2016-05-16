CREATE TABLE [fds].[dim_validation]
(
[enc_id] [uniqueidentifier] NOT NULL,
[enc_number] [numeric] (12, 0) NOT NULL,
[location_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[patient_name] [varchar] (121) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_rec_nbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enc_bill_date] [date] NULL,
[billable_encounter] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qualified_encounter] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
