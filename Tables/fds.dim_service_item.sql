CREATE TABLE [fds].[dim_service_item]
(
[service_item_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Service_Item_Group] [bigint] NULL,
[eff_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[exp_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpt4_code_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[current_price] [numeric] (19, 2) NOT NULL,
[revenue_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[form] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rental_duration_per_unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unassigned_benefit] [numeric] (19, 2) NULL,
[unassigned_benefit_fac] [numeric] (19, 2) NULL,
[rental_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[behavioral_billing_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[self_pay_fqhc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sliding_fee_fqhc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[clinic_rate_exempt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sliding_fee_exempt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fqhc_enc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[delete_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
