CREATE TABLE [fds].[dim_medication]
(
[ndc_id] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gcn_seqno] [int] NULL,
[hicl_seqno] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medid] [numeric] (8, 0) NULL,
[gcn] [int] NULL,
[brand_name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[generic_name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dose] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dose_form_desc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[route_desc] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_class] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[med_sched] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gen_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[del_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
