CREATE TABLE [dwh].[data_person_nd_month]
(
[per_mon_id] [int] NOT NULL IDENTITY(1, 1),
[person_id] [uniqueidentifier] NULL,
[person_id_ecw] [int] NULL,
[first_mon_date] [date] NULL,
[mh_cur_key] [int] NULL,
[mh_hx_key] [int] NULL,
[pcp_cur_key] [int] NULL,
[pcp_hx_key] [int] NULL,
[status_cur_key] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_hx_key] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_first_office_enc_date] [date] NULL,
[expired_date] [date] NULL,
[First_enc_age_months] [int] NULL,
[nbr_new_pt] [int] NOT NULL,
[nbr_pt_seen_office_ever] [int] NOT NULL,
[nbr_pt_deceased] [int] NULL,
[nbr_pt_deceased_this_month] [int] NOT NULL,
[patient_vintage] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[age_hx] [int] NULL,
[age_cur] [int] NULL,
[dob] [date] NULL,
[full_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middle_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_line_1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_line_2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sex] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssn] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[marital_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[race] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_rec_nbr] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ng_data] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dwh].[data_person_nd_month] ADD CONSTRAINT [per_mon_id_pk] PRIMARY KEY CLUSTERED  ([per_mon_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_person_mon_x_first_mon_date2] ON [dwh].[data_person_nd_month] ([per_mon_id], [first_mon_date]) ON [PRIMARY]
GO
