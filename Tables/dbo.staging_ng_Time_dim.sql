CREATE TABLE [dbo].[staging_ng_Time_dim]
(
[PK_Date] [datetime] NOT NULL,
[Date_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Year] [datetime] NULL,
[Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Half_Year] [datetime] NULL,
[Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quarter] [datetime] NULL,
[Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Trimester] [datetime] NULL,
[Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month] [datetime] NULL,
[Month_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ten_Days] [datetime] NULL,
[Ten_Days_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Week] [datetime] NULL,
[Week_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Year] [int] NULL,
[Day_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Half_Year] [int] NULL,
[Day_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Trimester] [int] NULL,
[Day_Of_Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Quarter] [int] NULL,
[Day_Of_Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Month] [int] NULL,
[Day_Of_Month_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Ten_Days] [int] NULL,
[Day_Of_Ten_Days_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day_Of_Week] [int] NULL,
[Day_Of_Week_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Week_Of_Year] [int] NULL,
[Week_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ten_Days_Of_Year] [int] NULL,
[Ten_Days_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ten_Days_Of_Half_Year] [int] NULL,
[Ten_Days_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ten_Days_Of_Trimester] [int] NULL,
[Ten_Days_Of_Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ten_Days_Of_Quarter] [int] NULL,
[Ten_Days_Of_Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ten_Days_Of_Month] [int] NULL,
[Ten_Days_Of_Month_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month_Of_Year] [int] NULL,
[Month_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month_Of_Half_Year] [int] NULL,
[Month_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month_Of_Trimester] [int] NULL,
[Month_Of_Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month_Of_Quarter] [int] NULL,
[Month_Of_Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quarter_Of_Year] [int] NULL,
[Quarter_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quarter_Of_Half_Year] [int] NULL,
[Quarter_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Trimester_Of_Year] [int] NULL,
[Trimester_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Half_Year_Of_Year] [int] NULL,
[Half_Year_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Year] [datetime] NULL,
[Fiscal_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Half_Year] [datetime] NULL,
[Fiscal_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Quarter] [datetime] NULL,
[Fiscal_Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Trimester] [datetime] NULL,
[Fiscal_Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Month] [datetime] NULL,
[Fiscal_Month_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Week] [datetime] NULL,
[Fiscal_Week_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day] [datetime] NULL,
[Fiscal_Day_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day_Of_Year] [int] NULL,
[Fiscal_Day_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day_Of_Half_Year] [int] NULL,
[Fiscal_Day_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day_Of_Trimester] [int] NULL,
[Fiscal_Day_Of_Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day_Of_Quarter] [int] NULL,
[Fiscal_Day_Of_Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day_Of_Month] [int] NULL,
[Fiscal_Day_Of_Month_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Day_Of_Week] [int] NULL,
[Fiscal_Day_Of_Week_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Week_Of_Year] [int] NULL,
[Fiscal_Week_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Month_Of_Year] [int] NULL,
[Fiscal_Month_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Month_Of_Half_Year] [int] NULL,
[Fiscal_Month_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Month_Of_Trimester] [int] NULL,
[Fiscal_Month_Of_Trimester_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Month_Of_Quarter] [int] NULL,
[Fiscal_Month_Of_Quarter_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Trimester_Of_Year] [int] NULL,
[Fiscal_Trimester_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Quarter_Of_Year] [int] NULL,
[Fiscal_Quarter_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Quarter_Of_Half_Year] [int] NULL,
[Fiscal_Quarter_Of_Half_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fiscal_Half_Year_Of_Year] [int] NULL,
[Fiscal_Half_Year_Of_Year_Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Relative_days_to_CurrentDate] [int] NULL,
[Relative_months_to_CurrentDate] [int] NULL,
[Relative_weeks_to_CurrentDate] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[staging_ng_Time_dim] ADD CONSTRAINT [PK_Time2010to2020] PRIMARY KEY CLUSTERED  ([PK_Date]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', NULL, NULL
GO
EXEC sp_addextendedproperty N'DSVTable', N'Time2010to2020', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', NULL, NULL
GO
EXEC sp_addextendedproperty N'Project', N'3c97210e-f5b4-4fd4-b06e-06f30b58f835', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', NULL, NULL
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Date_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Date_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Date_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Month'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Month', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Month'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Month_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Month_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Month_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Ten_Days'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Ten_Days', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Ten_Days'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Ten_Days_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Ten_Days_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Ten_Days_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Week'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Week', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Week'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Week_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Week_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Week_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Day_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Day_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Month'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Month', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Month'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Month_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Month_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Month_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Week'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Week', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Week'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Week_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Week_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Week_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Day_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Day_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Half_Year_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Half_Year_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Half_Year_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Month_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Month_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Quarter_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Quarter_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Quarter_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Quarter_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Quarter_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Trimester_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Trimester_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Trimester_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Week', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Week_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Week_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Week_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Week_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Fiscal_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Fiscal_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Half_Year_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Half_Year_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Half_Year_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Month_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Month_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'PK_Date'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Date', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'PK_Date'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Quarter_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Quarter_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Quarter_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Quarter_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Quarter_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Half_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Half_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Half_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Half_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Month'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Month', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Month'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Month_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Month_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Month_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Quarter'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Quarter', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Quarter'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Quarter_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Quarter_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Ten_Days_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Ten_Days_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Trimester', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Trimester_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Trimester_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Trimester_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Trimester_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Week', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Week_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week_Of_Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Week_Of_Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week_Of_Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Week_Of_Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Week_Of_Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Year'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Year', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Year'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Year_Name'
GO
EXEC sp_addextendedproperty N'DSVColumn', N'Year_Name', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'COLUMN', N'Year_Name'
GO
EXEC sp_addextendedproperty N'AllowGen', N'True', 'SCHEMA', N'dbo', 'TABLE', N'staging_ng_Time_dim', 'CONSTRAINT', N'PK_Time2010to2020'
GO
