CREATE TABLE [fds].[dim_category]
(
[category_id] [uniqueidentifier] NOT NULL,
[slot_category] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prevent_appts] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
