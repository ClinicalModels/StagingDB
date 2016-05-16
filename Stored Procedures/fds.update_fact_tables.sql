SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fds].[update_fact_tables]
AS
    BEGIN

        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        IF OBJECT_ID('fds.fact_pharmacy') IS NOT NULL
            DROP TABLE fds.fact_pharmacy;
        IF OBJECT_ID('fds.fact_encounter') IS NOT NULL
            DROP TABLE fds.fact_encounter;
     
        IF OBJECT_ID('fds.fact_charge') IS NOT NULL
            DROP TABLE fds.fact_charge;    
        IF OBJECT_ID('fds.fact_transaction') IS NOT NULL
            DROP TABLE fds.fact_transaction;

        SELECT  per.per_mon_id ,
                pha.[person_id] ,
                pha.[location_id] ,
                [provider_id] ,
                [md_id] ,
                [enc_id] ,
                [rx_id] ,
                [gcnsecno] ,
                [ndc] ,
                [store_id] ,
                CAST([start_date] AS DATE) start_date ,
                CAST([expire_date] AS DATE) expire_date ,
                [RxNotbyProv] ,
                [written_qty] ,
                [refills_left] ,
                [refills_orig] ,
                [drug_dea_class] ,
                [operation_type] ,  -- needs a junk dim table
                [Total_Non_Controlled] ,
                [Total_Controlled] ,
                [Sched_I] ,
                [Sched_II] ,
                [Sched_III] ,
                [Sched_IV] ,
                [Sched_V]
        INTO    fds.fact_pharmacy
        FROM    dwh.data_pharmacy pha
                INNER JOIN dwh.data_person_month per ON per.person_id = pha.person_id
                                                        AND per.seq_date = CAST(CONVERT(CHAR(6), pha.start_date, 112)
                                                        + '01' AS DATE);
	 
	 
	   --Caveat here is that start_date can be set by the provider to a future date
	   --When we use person_mon_id to map data to will flow to start date, but the rx will get mapped to the encounter -- this may create some inconsistencies in the data displayed



        WITH    enc_stat
                  AS ( SELECT   ROW_NUMBER() OVER ( ORDER BY enc_status, billable_enc_ct, qual_enc_ct ) AS EncStatusKey ,
                                x1.enc_status ,
                                x2.billable_enc_ct ,
                                x3.qual_enc_ct ,
                                CASE WHEN enc_status = 'U' THEN 'Unbilled'
                                     WHEN enc_status = 'R' THEN 'Rebilled'
                                     WHEN enc_status = 'H' THEN 'History'
                                     WHEN enc_status = 'B' THEN 'Billed'
                                     WHEN enc_status = 'D' THEN 'Bad Debt'
                                     ELSE 'Unknown'
                                END AS Encounter_status ,
                                CASE WHEN [billable_enc_ct] = 1 THEN 'Billable'
                                     ELSE 'Not Billable'
                                END AS Billable_ind ,
                                CASE WHEN [qual_enc_ct] = 1 THEN 'Qualified'
                                     ELSE 'Not Qualified'
                                END AS Qual_ind
                       FROM     ( SELECT DISTINCT
                                            enc_status
                                  FROM      [Staging_Ghost].[dwh].data_encounter
                                ) x1
                                CROSS JOIN ( SELECT DISTINCT
                                                    billable_enc_ct
                                             FROM    [Staging_Ghost].[dwh].data_encounter
                                           ) x2
                                CROSS JOIN ( SELECT DISTINCT
                                                    qual_enc_ct
                                             FROM   [Staging_Ghost].[dwh].data_encounter
                                           ) x3
                     )
            SELECT  sta.EncStatusKey ,
                    per.per_mon_id ,
                    enc.*
            INTO    fds.fact_encounter
            FROM    [Staging_Ghost].[dwh].[data_encounter] enc
                    LEFT JOIN enc_stat sta ON enc.enc_status = sta.enc_status
                                              AND enc.billable_enc_ct = sta.billable_enc_ct
                                              AND enc.qual_enc_ct = sta.qual_enc_ct
                    LEFT JOIN dwh.data_person_month per ON enc.person_id = per.person_id
                                                             AND per.seq_date = CAST(CONVERT(CHAR(6), enc.enc_bill_date, 112)
                                                             + '01' AS DATE);



  
        SELECT  *
        INTO    fds.fact_charge
        FROM    [Staging_Ghost].[dwh].[data_charge];


		
		
        SELECT  *
        INTO    fds.fact_transaction
        FROM    [Staging_Ghost].[dwh].data_transaction; 



		SELECT 
	   [location_id]
      ,[person_id]
      ,[pcp_id_cur_mon]
      ,[per_mon_id]
      ,[seq_date]
      ,[first_mon_date]
      ,[CurMon_Pt_Age]
      ,[MemberMonths]
      ,[Nbr_new_pt]
      ,[Nbr_pt_ever_enrolled]
      ,[nbr_pt_deceased]
      ,[nbr_pt_deceased_this_month]
      ,[nbr_ap_controlled_rx]
      ,[nbr_ap_no_controlled_rx]
      ,[nbr_ap_no_show]
      ,[nbr_ap_cancelled]
      ,[nbr_ap_deleted]
      ,[nbr_ap_rescheduled]
      ,[nbr_ap_bill_w_appt]
      ,[nbr_ap_non_bill_w_appt]
      ,[nbr_ap_pcp_appt]
      ,[nbr_ap_nonpcp_Appt]
      ,[nbr_ap_kept_and_linked_enc]
      ,[nbr_ap_kept_not_linked_enc]
      ,[nbr_enc_w_charges_not_linked_appt]
      ,[nbr_enc_w_charges]
      ,[ap_avg_cycle_min_slottime_to_kept]
      ,[ap_avg_cycle_min_kept_checkedout]
      ,[nbr_chronic_pain_12m]
      ,[nbr_pt_act_3m]
      ,[nbr_pt_act_6m]
      ,[nbr_pt_act_12m]
      ,[nbr_pt_act_18m]
      ,[nbr_pt_act_24m]
      
	  FROM dwh.data_person_month


    END;
GO
