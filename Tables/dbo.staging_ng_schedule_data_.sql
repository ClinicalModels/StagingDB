CREATE TABLE [dbo].[staging_ng_schedule_data_]
(
[seq_no] [uniqueidentifier] NOT NULL,
[location_id] [uniqueidentifier] NULL,
[prov_res_id] [uniqueidentifier] NULL,
[provider_id] [uniqueidentifier] NULL,
[resource_id] [uniqueidentifier] NULL,
[slot_category_id] [uniqueidentifier] NULL,
[appt_template_id] [uniqueidentifier] NULL,
[practice_id] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_by] [int] NOT NULL,
[create_timestamp] [datetime] NOT NULL CONSTRAINT [DF__staging_n__creat__36B12243] DEFAULT (getdate()),
[modified_by] [int] NOT NULL,
[modify_timestamp] [datetime] NOT NULL CONSTRAINT [DF__staging_n__modif__37A5467C] DEFAULT (getdate()),
[create_timestamp_tz] [smallint] NULL,
[modify_timestamp_tz] [smallint] NULL,
[row_timestamp] [timestamp] NOT NULL,
[appt_template_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[appts_ind] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[daily_template_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exception_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[patients_ind] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prevent_appts_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resource_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_mon] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_week] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[slot_begin_time] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[slot_category] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[slot_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[slot_end_time] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[working_ind] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[slot_duration] [int] NULL,
[slot_date_dt] [date] NULL,
[prov_res_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prov_res_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sched_min_tot_dur] [decimal] (16, 2) NULL,
[sched_min_working_dur] [decimal] (16, 2) NULL,
[sched_min_patients_dur] [decimal] (16, 2) NULL,
[sched_min_no_appts_dur] [decimal] (16, 2) NULL,
[sched_hrs_tot_dur] [decimal] (16, 2) NULL,
[sched_hrs_working_dur] [decimal] (16, 2) NULL,
[sched_hrs_clinical_dur] [decimal] (16, 2) NULL,
[sched_hrs_no_appts_dur] [decimal] (16, 2) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sd_locid] ON [dbo].[staging_ng_schedule_data_] ([location_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sd_bt] ON [dbo].[staging_ng_schedule_data_] ([slot_begin_time]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sd_sd] ON [dbo].[staging_ng_schedule_data_] ([slot_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sd_sdt] ON [dbo].[staging_ng_schedule_data_] ([slot_date_dt]) ON [PRIMARY]
GO
