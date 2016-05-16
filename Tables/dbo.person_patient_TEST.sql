CREATE TABLE [dbo].[person_patient_TEST]
(
[person_id] [uniqueidentifier] NOT NULL,
[expired_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primarycare_prov_id] [uniqueidentifier] NULL,
[full_name] [varchar] (147) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[first_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[middle_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dob] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_line_1] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_line_2] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sex] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssn] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[marital_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[race] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ethnicity] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_rec_nbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
