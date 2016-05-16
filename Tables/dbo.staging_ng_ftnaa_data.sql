CREATE TABLE [dbo].[staging_ng_ftnaa_data]
(
[seq_no] [uniqueidentifier] NULL,
[resource_id] [uniqueidentifier] NOT NULL,
[provider_id] [uniqueidentifier] NULL,
[location_id] [uniqueidentifier] NULL,
[event_id] [uniqueidentifier] NULL,
[resource_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider_desc] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[days_away] [int] NULL,
[appt_date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[begintime] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ranking] [int] NULL,
[rank_txt] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[appt_datetime] [datetime] NULL,
[run_date] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[run_date_dt] [date] NULL
) ON [PRIMARY]
GO
