CREATE TABLE [dwh].[data_user]
(
[user_key] [int] NOT NULL IDENTITY(1, 1),
[enterprise_id] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[practice_id] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [int] NOT NULL,
[provider_id] [uniqueidentifier] NULL,
[last_name] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mi] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_login_id] [varchar] (320) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[login_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_logon_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delete_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_by] [int] NOT NULL,
[create_timestamp] [datetime] NOT NULL,
[credentialed_staff_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FullName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
