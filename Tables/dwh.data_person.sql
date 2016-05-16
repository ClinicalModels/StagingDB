CREATE TABLE [dwh].[data_person]
(
[person_id] [uniqueidentifier] NOT NULL,
[VintageYM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Person_rec_Creation_Dt] [datetime] NOT NULL,
[Deceased] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deceased_dt] [date] NULL,
[first_office_enc_date] [date] NULL,
[last_office_enc_date] [date] NULL,
[First_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[full_Name] [varchar] (121) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[middle_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[suffix] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prefix] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[degree] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address_line_1] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address_line_2] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[city] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[country] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[county] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[home_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[day_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[alt_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DOB] [date] NULL,
[Age_Nbr_Today] [int] NULL,
[Age_Range_Today] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sex] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ssn] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[marital_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[smoker] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[veteran] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[race] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[student_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pcp_id_today] [uniqueidentifier] NULL,
[pcp_name_today] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ethinicity] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[med_rec_nbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberMonths] [int] NULL,
[location_id] [uniqueidentifier] NULL,
[location_name_UD] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Is_New_Patient] [int] NULL,
[Is_act_3m] [int] NULL,
[Is_act_6m] [int] NULL,
[Is_act_12m] [int] NULL,
[Is_act_18m] [int] NULL,
[Is_act_24m] [int] NULL
) ON [PRIMARY]
GO