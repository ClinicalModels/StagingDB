CREATE TABLE [fds].[dim_event]
(
[event_id] [uniqueidentifier] NOT NULL,
[event_short_name] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[duration] [int] NULL,
[prevent_appt_reminder] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[require_linked_appt] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mark_as_Deleted] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
