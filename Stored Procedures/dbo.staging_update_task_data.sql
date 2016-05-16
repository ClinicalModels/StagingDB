SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_task_data]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
	
        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);

        SET @build_dt_start = CONVERT(VARCHAR(8), GETDATE(), 112); --This routine will build current and hx data from begin to end date 
        SET @build_dt_end = CONVERT(VARCHAR(8), GETDATE(), 112);

        SET @build_dt_start = '20100101';

--set @build_dt_end =   '20100202'
--set @build_dt_end =   '20150701'
 


        IF OBJECT_ID('[dwh].[data_task]') IS NOT NULL
            DROP TABLE dwh.data_task; 


        WITH    TasksRaw
                  AS ( SELECT   ut1.created_by AS task_from_user_id -- who orginated the task
                                ,
                                ut1.task_owner AS task_to_user_id --who the task was sent to do 
                                ,
                                ut1.pat_acct_id --person_id of patient tasked about
                                ,
                                ut1.pat_enc_id --encounter
                                ,
                                ut1.task_id ,
                                CAST(ut1.task_id AS VARCHAR(36)) AS task_id_vchar ,
                                CAST(ut1.pat_acct_id AS VARCHAR(36)) AS pat_acct_id_vchar ,
                                CAST(ut1.pat_enc_id AS VARCHAR(36)) AS pat_enc_id_vchar ,
                                CAST(ut1.task_owner AS VARCHAR(36)) AS task_to_user_id_vchar ,
                                CAST(ut1.created_by AS VARCHAR(36)) AS task_from_user_id_vchar ,
                                CAST(ut1.create_timestamp AS DATE) create_timestamp-- when created
              --,ut1.modify_timestamp -- likely when it was addressed
                                ,
                                DATEDIFF(hh, ut1.create_timestamp, ut1.modify_timestamp) AS HourstoCompeletion ,
                                DATEDIFF(mi, ut1.create_timestamp, ut1.modify_timestamp) AS MinutestoCompeletion ,
                                ut1.task_completed ,
                                ut1.task_assgn ,
                                ut1.read_flag ,
                                ut1.rejected_ind ,
                                ut1.pat_item_type --refill or telephone consult
                                ,
                                ut1.task_desc ,
                                ut1.task_subj -- what its for? --,per.last_name
                                ,
                                ( CASE WHEN ISDATE(ut1.create_timestamp) = 1 THEN CAST(ut1.create_timestamp AS DATE)
                                  END ) AS create_date ,
                                pe.location_id
                       FROM     [10.183.0.94].NGProd.dbo.user_todo_list ut1
                                LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter pe ON pe.enc_id = ut1.pat_enc_id
                       WHERE    ( ut1.create_timestamp >= CAST(@build_dt_start AS DATE) )
                                AND ( ut1.create_timestamp <= CAST(@build_dt_end AS DATE) )
                     )
            --Build Task Fact Table  DataMart

        SELECT  per.person_id ,
                t.location_id ,
                per.per_mon_id ,
                t.pat_enc_id AS enc_id ,
                [task_id] AS NG_task_id ,
                IDENTITY( INT, 1, 1 )  AS Tsk_id ,
                create_timestamp ,
                task_from_user_id ,
                task_to_user_id ,
                CAST(CONVERT(CHAR(6), t.create_timestamp, 112) + '01' AS DATE) seq_date ,
                CASE WHEN task_completed = 1 THEN 'Task Completed'
                     ELSE 'Task Not Complete'
                END AS Task_completed ,
                CASE WHEN task_assgn = 'A' THEN 'Task Assigned'
                     ELSE 'Task Not Assigned'
                END AS Task_Assigned ,
                CASE WHEN read_flag = 'Y' THEN 'Task Read'
                     ELSE 'Task Not Read'
                END AS Task_Read ,
                CASE WHEN rejected_ind = 'Y' THEN 'Task Rejected'
                     ELSE 'Task Accepted'
                END AS Task_rejected ,
                task_desc ,
                --Request_Type ,
                task_subj ,
                CASE WHEN pat_item_type = 'U'
                          AND task_desc = 'Failed to Match SureScripts Request' THEN 'Failed SureScripts'
                     WHEN pat_item_type = 'R' THEN 'Pharmacy Refill Request'
                     WHEN task_subj = 'Referral Order' THEN 'Referral Order'
                     WHEN task_subj = 'Referral Order:' THEN 'Referral Order'
                     WHEN task_subj LIKE '%Referral%' THEN 'Referral Related'
                     WHEN task_subj LIKE '%Lab%' THEN 'Lab Related'
                                    -- WHEN pat_item_type = 'T'
                                     --     AND task_subj != '' THEN task_subj
                                     --WHEN pat_item_type = 'L'
                                       --   AND task_subj != '' THEN task_subj
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%pap%' THEN 'Pap Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%BP%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%Blood Pressure%' THEN 'Blood Pressure Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%consult%' THEN 'Consultations'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%group%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%yoga%' THEN 'Groups'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%appointment%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%appt%' THEN 'Scheduling'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%walkin%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%walk-in%' THEN 'Walk-ins'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%ORDER PRO%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%appt%' THEN 'Order Awaiting Action'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'admitted'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%hospital%' THEN 'Admitted or Hospital Follow up'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'FYI' THEN 'FYI'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'DME' THEN 'DME'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'HomeHealth'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%Home Health%' THEN 'Home Health'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'Controlled'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%pain%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%utox%' THEN 'Pain Related'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE 'medicaiton'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%renew%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%refill%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%pharmacist%' THEN 'Medication Issues'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%ERR%' THEN 'Error Erx'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%CHART%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%Medical Records%' THEN 'Medical Record Requests'
                     WHEN CONCAT(task_desc, ' ', task_subj) LIKE '%MRI'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%ultrasound%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%CT%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%scans%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%mammogram%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%xray%'
                          OR CONCAT(task_desc, ' ', task_subj) LIKE '%xry%' THEN 'Imaging'
                  
					 
					 
					 ELSE 'Other'
                END AS Request_Type ,
                CASE WHEN HourstoCompeletion > 336 THEN NULL
                     ELSE HourstoCompeletion
                END AS Mod_Hourstocompletion ,
                CASE WHEN HourstoCompeletion > 336 THEN NULL
                     ELSE MinutestoCompeletion
                END AS Mod_MinutestoCompeletion ,
                CASE WHEN HourstoCompeletion > ( 24 * 7 ) THEN HourstoCompeletion
                END AS HourstoCompGreaterWeek ,
                CASE WHEN HourstoCompeletion <= ( 24 * 7 ) THEN HourstoCompeletion
                END AS HourstoCompLessWeek ,
                HourstoCompeletion ,
                MinutestoCompeletion
        INTO    Staging_Ghost.dwh.data_task
        FROM    TasksRaw t
                INNER JOIN staging_ng_data_person_ per ON t.pat_acct_id = per.person_id
                                                          AND per.seq_date = CAST(CONVERT(CHAR(6), t.create_timestamp, 112)
                                                          + '01' AS DATE)
        WHERE   ( t.create_timestamp >= CAST(@build_dt_start AS DATE) )
                AND ( t.create_timestamp <= CAST(@build_dt_end AS DATE) );
  




    END;
GO
