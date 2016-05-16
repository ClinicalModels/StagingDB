CREATE TABLE [dwh].[secure_allocation]
(
[Allocated Cost Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allocated Cost Number Percent] [float] NULL,
[Allocated Cost Number Position] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Business Unit Code] [int] NULL,
[Business Unit Desc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company/Cost Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company/Dept] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[File Number] [int] NULL,
[Home Cost Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home Department] [int] NULL,
[Payroll First Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payroll Last Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payroll Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate Amount] [float] NULL,
[Rate Type Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate Type Desc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN Masked] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
