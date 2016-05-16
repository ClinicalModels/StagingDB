CREATE TABLE [dwh].[data_person_month]
(
[per_mon_id] [int] NOT NULL IDENTITY(1, 1),
[person_id] [uniqueidentifier] NOT NULL,
[pcp_id_cur] [uniqueidentifier] NULL,
[pcp_id_day] [int] NULL,
[first_mon_date] [date] NULL,
[date_of_birth] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberMonths] [int] NULL,
[Nbr_new_pt] [int] NULL,
[Nbr_pt_ever_enrolled] [int] NOT NULL,
[nbr_pt_deceased] [int] NULL,
[nbr_pt_deceased_this_month] [int] NULL,
[location_id] [uniqueidentifier] NULL,
[CurMon_Pt_Age] [int] NULL,
[nbr_chronic_pain_12m] [int] NOT NULL,
[nbr_chronic_pain_6m] [int] NOT NULL,
[nbr_pt_act_3m] [int] NOT NULL,
[nbr_pt_act_6m] [int] NOT NULL,
[nbr_pt_act_12m] [int] NOT NULL,
[nbr_pt_act_18m] [int] NOT NULL,
[nbr_pt_act_24m] [int] NOT NULL,
[rank_order] [bigint] NULL
) ON [PRIMARY]
GO
