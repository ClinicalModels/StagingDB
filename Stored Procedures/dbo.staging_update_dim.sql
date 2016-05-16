SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_dim]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


    -- Insert statements for procedure here


        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        IF OBJECT_ID('dbo.staging_ng_dim_task_') IS NOT NULL
            DROP TABLE staging_ng_dim_task_;


IF OBJECT_ID('[fds].[dim_event]') IS NOT NULL
            DROP TABLE [fds].[dim_event];


IF OBJECT_ID('[fds].dim_category') IS NOT NULL
            DROP TABLE [fds].dim_category;
			

        IF OBJECT_ID('dbo.staging_ng_fact_task_') IS NOT NULL
            DROP TABLE dbo.staging_ng_fact_task_;
        IF OBJECT_ID('fds.dim_location') IS NOT NULL
            DROP TABLE fds.dim_location;
        IF OBJECT_ID('dbo.staging_ng_slot_category_') IS NOT NULL
            DROP TABLE staging_ng_slot_category_;
        IF OBJECT_ID('dbo.staging_ng_link_cat_event_') IS NOT NULL
            DROP TABLE staging_ng_link_cat_event_;
        IF OBJECT_ID('dbo.staging_ng_event_') IS NOT NULL
            DROP TABLE staging_ng_event_;
        IF OBJECT_ID('dbo.staging_ng_location_') IS NOT NULL
            DROP TABLE staging_ng_location_;
        IF OBJECT_ID('dbo.staging_ng_user_') IS NOT NULL
            DROP TABLE staging_ng_user_;
        IF OBJECT_ID('dbo.staging_ng_link_prov_user_') IS NOT NULL
            DROP TABLE staging_ng_link_prov_user_;
        IF OBJECT_ID('dbo.staging_ng_link_prov_res_') IS NOT NULL
            DROP TABLE [Staging_Ghost].[dbo].[staging_ng_link_prov_res_];
        IF OBJECT_ID('dbo.staging_ng_resource_') IS NOT NULL
            DROP TABLE [Staging_Ghost].[dbo].[staging_ng_resource_]; 
        IF OBJECT_ID('dbo.staging_ng_provider_') IS NOT NULL
            DROP TABLE [Staging_Ghost].[dbo].[staging_ng_provider_];
        IF OBJECT_ID('dbo.[staging_ng_dim_cpt4_]') IS NOT NULL
            DROP TABLE [Staging_Ghost].[dbo].[staging_ng_dim_cpt4_];
        IF OBJECT_ID('staging_ng_bridge_person_encounter_') IS NOT NULL
            DROP TABLE staging_ng_bridge_person_encounter_; 
        IF OBJECT_ID('staging_ng_dim_encounter_status_') IS NOT NULL
            DROP TABLE staging_ng_dim_encounter_status_;
        IF OBJECT_ID('staging_ng_fact_encounter_') IS NOT NULL
            DROP TABLE staging_ng_fact_encounter_;
        IF OBJECT_ID('staging_ng_bridge_encounter_charge_') IS NOT NULL
            DROP TABLE staging_ng_bridge_encounter_charge_;
        IF OBJECT_ID('staging_ng_bridge_charge_transaction_') IS NOT NULL
            DROP TABLE staging_ng_bridge_charge_transaction_;
        IF OBJECT_ID('staging_ng_fact_Charge_') IS NOT NULL
            DROP TABLE staging_ng_fact_Charge_;

 


        SELECT  category_id ,
                category AS slot_category

        INTO    [dbo].[staging_ng_slot_category_] 
        FROM    [10.183.0.94].NGProd.dbo.[categories];


		SELECT  category_id ,
                COALESCE(category,'') AS slot_category
				,COALESCE([prevent_appts_ind],'') AS prevent_appts

        INTO    [fds].dim_category
        FROM    [10.183.0.94].NGProd.dbo.[categories];


--Build Linking metric table in staging
        SELECT  category_id ,
                event_id
        INTO    [dbo].[staging_ng_link_cat_event_]
        FROM    [10.183.0.94].NGProd.dbo.[category_members]; 

--Build Event Table in staging

        SELECT DISTINCT
                event_id ,
                event_short ,
                event
        INTO    [dbo].[staging_ng_event_]
        FROM    [10.183.0.94].NGProd.dbo.[events];

		SELECT DISTINCT
                event_id ,
                COALESCE(event_short,'')  AS event_short_name
                ,COALESCE(event,'') AS event
			 ,COALESCE([duration],'') AS duration
         ,COALESCE([suppress_appt_reminder_ind],'') AS prevent_appt_reminder
      ,COALESCE([require_linked_appt_ind],'') AS require_linked_appt
         ,COALESCE([delete_ind],'') AS Mark_as_Deleted
     
        INTO    [fds].[dim_event]
        FROM    [10.183.0.94].NGProd.dbo.[events];


        SELECT DISTINCT
                loc.location_id ,
                loc.location_name
        INTO    dbo.staging_ng_location_
        FROM    [10.183.0.94].NGProd.dbo.patient_encounter AS enc
                LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.location_mstr AS loc ON enc.location_id = loc.location_id
        WHERE   ( loc.location_name <> '' )
                AND ( enc.practice_id = '0001' );

        SELECT DISTINCT
                loc.location_id ,
                loc.location_name ,
                loc.ud_demo3_id AS location_user_id ,
                loc.healthpac_id
        INTO    fds.dim_location
        FROM    dwh.data_location loc;

        SELECT  provider_id = prov.provider_id ,
                provider_name = prov.description ,
                prov.ssn ,
                prov.primary_loc_id ,
                COALESCE(prov.degree, '') AS degree ,
                prov.first_name ,
                prov.last_name ,
                prov.middle_name ,
                prov.city ,
                prov.state ,
                prov.zip
        INTO    [Staging_Ghost].[dbo].[staging_ng_provider_]
        FROM    [10.183.0.94].[NGProd].[dbo].[provider_mstr] prov;

        SELECT  resource_id = r.resource_id ,
                resource_name = r.description
        INTO    [Staging_Ghost].[dbo].[staging_ng_resource_]
        FROM    [10.183.0.94].[NGProd].[dbo].[resources] r;

        SELECT DISTINCT
                seqnum = NEWID() ,
                provider_id = prov.provider_id ,
                resource_id = r.resource_id
        INTO    [Staging_Ghost].[dbo].[staging_ng_link_prov_res_]
        FROM    [10.183.0.94].[NGProd].[dbo].[resources] r
                INNER JOIN [10.183.0.94].[NGProd].[dbo].[provider_mstr] prov ON r.phys_id = prov.provider_id;
	

        UPDATE  [dbo].[staging_ng_Time_dim]
        SET     [Relative_days_to_CurrentDate] = DATEDIFF(DAY, PK_Date, GETDATE());


        UPDATE  [dbo].[staging_ng_Time_dim]
        SET     [Relative_weeks_to_CurrentDate] = DATEDIFF(WEEK, PK_Date, GETDATE());


        UPDATE  [dbo].[staging_ng_Time_dim]
        SET     [Relative_months_to_CurrentDate] = DATEDIFF(MONTH, PK_Date, GETDATE());





        SELECT  [enterprise_id] ,
                [practice_id] ,
                [user_id] ,
                provider_id ,
                [last_name] ,
                [first_name] ,
                [mi] ,
                [start_date] ,
                [email_login_id] ,
                [login_id] ,
                [last_logon_date] ,
                [delete_ind] ,
                [created_by] ,
                [create_timestamp] ,
                [credentialed_staff_ind] ,
                CONCAT(first_name, ' ', last_name) AS FullName
        INTO    [dbo].[staging_ng_user_]
        FROM    [10.183.0.94].[NGProd].[dbo].[user_mstr];

        SELECT  DISTINCT
                user_id ,
                provider_id
        INTO    [dbo].[staging_ng_link_prov_user_]
        FROM    [10.183.0.94].[NGProd].[dbo].[user_mstr];




/****** Script for SelectTopNRows command from SSMS  ******/

--create dimensions for denial reason,  payer, financial class,service item ID (charges), days_to_(junk dimension) -- (this will need clean up -- as might need to set a flag in the fact table for >x number of days, transaction codes

--create a link table for payer dimension
--create a fact table for charges
--create a fact table for transations





        SELECT  ROW_NUMBER() OVER ( ORDER BY enc_status, billable_enc_ct, qual_enc_ct ) AS EncStatusKey ,
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
        INTO    staging_ng_dim_encounter_status_
        FROM    ( SELECT DISTINCT
                            enc_status
                  FROM      [Staging_Ghost].[dbo].[staging_ng_data_encounter_]
                ) x1
                CROSS JOIN ( SELECT DISTINCT
                                    billable_enc_ct
                             FROM   [Staging_Ghost].[dbo].[staging_ng_data_encounter_]
                           ) x2
                CROSS JOIN ( SELECT DISTINCT
                                    qual_enc_ct
                             FROM   [Staging_Ghost].[dbo].[staging_ng_data_encounter_]
                           ) x3;

        SELECT  sta.EncStatusKey ,
                per.per_mon_id ,
                enc.*
        INTO    staging_ng_fact_encounter_
        FROM    [Staging_Ghost].[dbo].[staging_ng_data_encounter_] enc
                LEFT JOIN staging_ng_dim_encounter_status_ sta ON enc.enc_status = sta.enc_status
                                                                  AND enc.billable_enc_ct = sta.billable_enc_ct
                                                                  AND enc.qual_enc_ct = sta.qual_enc_ct
                LEFT JOIN staging_ng_data_person_ per ON enc.person_id = per.person_id
                                                         AND per.seq_date = CAST(CONVERT(CHAR(6), enc.enc_bill_date, 112)
                                                         + '01' AS DATE);

DELETE FROM dbo.staging_ng_fact_encounter_
WHERE per_mon_id IS null
  
  --create a fact and dimension tables for tasks



        SELECT  ROW_NUMBER() OVER ( ORDER BY Task_completed, Task_Assigned, Task_Read, Task_rejected, Request_Type ) AS Task_status_key ,
                Task_completed ,
                Task_Assigned ,
                Task_Read ,
                Task_rejected ,
                Request_Type
        INTO    staging_ng_dim_task_
        FROM    ( SELECT DISTINCT
                            Task_completed
                  FROM      Staging_Ghost.dwh.data_task
                ) x1
                CROSS JOIN ( SELECT DISTINCT
                                    Task_Assigned
                             FROM   Staging_Ghost.dwh.data_task
                           ) x2
                CROSS JOIN ( SELECT DISTINCT
                                    Task_Read
                             FROM   Staging_Ghost.dwh.data_task
                           ) x3
                CROSS JOIN ( SELECT DISTINCT
                                    Task_rejected
                             FROM   Staging_Ghost.dwh.data_task
                           ) x4
                CROSS JOIN ( SELECT DISTINCT
                                    Request_Type
                             FROM   Staging_Ghost.dwh.data_task
                           ) x5;


        SELECT  st.Task_status_key ,
                tsk.*
        INTO    staging_ng_fact_task_
        FROM    [Staging_Ghost].[dwh].[data_task] tsk
                LEFT JOIN staging_ng_dim_task_ st ON st.Task_completed = tsk.Task_completed
                                                     AND st.Task_Assigned = tsk.Task_Assigned
                                                     AND tsk.Task_Read = st.Task_Read
                                                     AND tsk.Request_Type = st.Request_Type; 



  


--- 

        SELECT  [enc_id] ,
                charge_id
        INTO    staging_ng_bridge_encounter_charge_
        FROM    [Staging_Ghost].[dbo].[staging_ng_data_charge_]; 
  

        SELECT  charge_id ,
                trans_id
        INTO    staging_ng_bridge_charge_transaction_
        FROM    [Staging_Ghost].[dbo].[staging_ng_data_transaction_]; 



        SELECT  chg.*
        INTO    staging_ng_fact_Charge_
        FROM    [Staging_Ghost].[dbo].[staging_ng_data_charge_] chg;



        IF OBJECT_ID('dbo.[staging_ng_dim_cpt4_]') IS NOT NULL
            DROP TABLE [Staging_Ghost].[dbo].[staging_ng_dim_cpt4_];
        SELECT  [cpt4_code_id] ,
                ( FLOOR(RANK() OVER ( ORDER BY cpt4_code_id ) / 1000) + 1 ) AS CPT_Group ,
                [description] ,
                [type_of_service]
        INTO    [Staging_Ghost].[dbo].[staging_ng_dim_cpt4_]
        FROM    [10.183.0.94].[NGProd].[dbo].[cpt4_code_mstr]; 


    END;




/*
update el
  set el.pay1_name = pay.payer_name
    ,el.pay1_finclass = left(ml.mstr_list_item_desc,40)
from #e el
  inner join [10.183.0.94].NGPROD.dbo.encounter_payer ep
    on el.enc_id = ep.enc_id
  inner join [10.183.0.94].NGPROD.dbo.payer_mstr pay
    on ep.payer_id = pay.payer_id
  LEFT JOIN [10.183.0.94].NGPROD.dbo.mstr_lists ml
    on pay.financial_class = ml.mstr_list_item_id
  where ISNULL(ep.cob,0) = 1
*/




GO
