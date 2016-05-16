CREATE TABLE [fds].[dim_pharmacy]
(
[pharmacy_id] [uniqueidentifier] NOT NULL,
[Name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipcode] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleted_ind] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[store_number] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accept_erx] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[accept_rx_mail_order] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[accept_rx_fax] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
