CREATE TABLE [dbo].[staging_ng_event_]
(
[event_id] [uniqueidentifier] NOT NULL,
[event_short] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
