CREATE TABLE [dbo].[staging_ng_status_data_]
(
[enc_id] [uniqueidentifier] NOT NULL,
[person_id] [uniqueidentifier] NOT NULL,
[rendering_provider_id] [uniqueidentifier] NULL,
[location_id] [uniqueidentifier] NULL,
[created_by] [int] NOT NULL,
[modified_by] [int] NOT NULL,
[CheckinDate] [date] NULL,
[modify_timestamp] [datetime] NOT NULL,
[checkin_datetime] [datetime] NULL,
[txt_room] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txt_status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Min_Since_last_StatusUpdate] [int] NULL,
[Min_Kept_to_StatusUpdate] [int] NULL
) ON [PRIMARY]
GO
