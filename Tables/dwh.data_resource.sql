CREATE TABLE [dwh].[data_resource]
(
[resource_key] [int] NOT NULL IDENTITY(1, 1),
[resource_id] [uniqueidentifier] NOT NULL,
[resource_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
