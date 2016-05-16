CREATE TABLE [dbo].[staging_ng_fact_task_]
(
[Task_status_key] [bigint] NULL,
[person_id] [uniqueidentifier] NOT NULL,
[location_id] [uniqueidentifier] NULL,
[per_mon_id] [int] NOT NULL,
[enc_id] [uniqueidentifier] NULL,
[NG_task_id] [uniqueidentifier] NOT NULL,
[Tsk_id] [int] NOT NULL,
[create_timestamp] [date] NULL,
[task_from_user_id] [int] NOT NULL,
[task_to_user_id] [int] NULL,
[seq_date] [date] NULL,
[Task_completed] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task_Assigned] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task_Read] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task_rejected] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[task_desc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_subj] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Request_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mod_Hourstocompletion] [int] NULL,
[Mod_MinutestoCompeletion] [int] NULL,
[HourstoCompGreaterWeek] [int] NULL,
[HourstoCompLessWeek] [int] NULL,
[HourstoCompeletion] [int] NULL,
[MinutestoCompeletion] [int] NULL
) ON [PRIMARY]
GO
