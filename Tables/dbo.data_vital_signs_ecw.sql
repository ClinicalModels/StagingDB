CREATE TABLE [dbo].[data_vital_signs_ecw]
(
[encounter_id] [int] NOT NULL,
[person_id] [int] NOT NULL,
[weight_lb_clean] [decimal] (10, 2) NULL,
[bmi_clean] [decimal] (10, 2) NULL,
[height_inches_clean] [decimal] (10, 2) NULL,
[bp_syst] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bp_diast] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_timestamp] [datetime] NULL,
[recency_day] [bigint] NULL,
[recency_all] [bigint] NULL,
[bp_syst_clean] [decimal] (10, 2) NULL,
[bp_diast_clean] [decimal] (10, 2) NULL,
[height_cm_calc] [numeric] (14, 4) NULL,
[weight_kg_calc] [numeric] (17, 8) NULL,
[NextDate] [datetime] NULL
) ON [PRIMARY]
GO
