CREATE TABLE [dbo].[staging_ng_data_person_]
(
[person_id] [uniqueidentifier] NOT NULL,
[pcp_id_cur_mon] [uniqueidentifier] NULL,
[per_mon_id] [int] NOT NULL,
[seq_date] [date] NULL,
[CurMon_Pt_Age] [int] NULL,
[MemberMonths] [int] NULL,
[Nbr_new_pt] [int] NULL,
[Nbr_pt_ever_enrolled] [int] NOT NULL,
[nbr_pt_deceased] [int] NULL,
[nbr_pt_deceased_this_month] [int] NOT NULL,
[location_id] [uniqueidentifier] NULL,
[nbr_ap_controlled_rx] [int] NULL,
[nbr_ap_no_controlled_rx] [int] NULL,
[nbr_ap_no_show] [int] NULL,
[nbr_ap_cancelled] [int] NULL,
[nbr_ap_deleted] [int] NULL,
[nbr_ap_rescheduled] [int] NULL,
[nbr_ap_bill_w_appt] [int] NULL,
[nbr_ap_non_bill_w_appt] [int] NULL,
[nbr_ap_pcp_appt] [int] NULL,
[nbr_ap_nonpcp_Appt] [int] NULL,
[nbr_ap_kept_and_linked_enc] [int] NULL,
[nbr_ap_kept_not_linked_enc] [int] NULL,
[nbr_enc_w_charges_not_linked_appt] [int] NULL,
[nbr_enc_w_charges] [int] NULL,
[ap_avg_cycle_min_slottime_to_kept] [int] NULL,
[ap_avg_cycle_min_kept_checkedout] [int] NULL,
[nbr_chronic_pain_3m] [int] NOT NULL,
[nbr_chronic_pain_6m] [int] NOT NULL,
[nbr_chronic_pain_12m] [int] NOT NULL,
[nbr_pt_act_3m] [int] NOT NULL,
[nbr_pt_act_6m] [int] NOT NULL,
[nbr_pt_act_12m] [int] NOT NULL,
[nbr_pt_act_18m] [int] NOT NULL,
[nbr_pt_act_24m] [int] NOT NULL,
[rank_order] [bigint] NULL
) ON [PRIMARY]
GO
