CREATE TABLE [dwh].[data_pharmacy]
(
[person_id] [uniqueidentifier] NOT NULL,
[location_id] [uniqueidentifier] NOT NULL,
[provider_id] [uniqueidentifier] NOT NULL,
[first_mon_date] [date] NULL,
[md_id] [numeric] (8, 0) NOT NULL,
[enc_id] [uniqueidentifier] NULL,
[rx_id] [numeric] (8, 0) NULL,
[gcnsecno] [int] NULL,
[drug_name] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ndc] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[med_rec_nbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[store_id] [uniqueidentifier] NULL,
[start_date] [date] NULL,
[expire_date] [date] NULL,
[Provider_Name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RxNotbyProv] [int] NOT NULL,
[PatName] [varchar] (122) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[birth_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chart_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssn] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sig_text] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[written_qty] [int] NULL,
[refills_left] [int] NULL,
[refills_orig] [int] NULL,
[SentTo] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clinic] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drug_dea_class] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[operation_type] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mmyy] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Total_Non_Controlled] [int] NOT NULL,
[Total_Controlled] [int] NOT NULL,
[Sched_I] [int] NOT NULL,
[Sched_II] [int] NOT NULL,
[Sched_III] [int] NOT NULL,
[Sched_IV] [int] NOT NULL,
[Sched_V] [int] NOT NULL
) ON [PRIMARY]
GO
