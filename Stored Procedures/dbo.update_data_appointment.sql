SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_appointment]
AS
    BEGIN




        DECLARE @dys_back INT;

        DECLARE @prac_id CHAR(4);

        SET @dys_back = 2190;
        SET @prac_id = '0001';


        IF OBJECT_ID('dwh.data_appointment') IS NOT NULL
            DROP TABLE dwh.data_appointment;

  -- get auto update user id
        DECLARE @u INT;
        SET @u = ( SELECT   user_id
                   FROM     [10.183.0.94].NGProd.dbo.user_mstr
                   WHERE    first_name = 'AutoUpdate'
                 );
        IF @u IS NULL
            SET @u = 0;
      
  -- set time var
        DECLARE @t DATETIME;
        SET @t = GETDATE();



/*
-- all appts from start date forward
-- include enc info if available, but get standalone appts as well
-- get all appts regardless of cancel/resched/delete status

-- 2nd query to get standalone encounters as well


link between appts and slots based on 
- date
- begintime
- resource
- location

*/

-- calculate start date
        DECLARE @dt_start VARCHAR(8);
        SELECT  @dt_start = '20100301'; 
        DECLARE @x INT;
        DECLARE @i INT;

--DELETE
--FROM [10.183.0.94].NGPROD.dbo.chcn_ccb_enc_w_appts_ep_
--where appt_date >= @dt_start
 -- or enc_date >= @dt_start


-- use last modified person resource to deal with any multi-resource appts
        SELECT  resource_id ,
                appt_id ,
                interval
        INTO    #ar
        FROM    ( SELECT    am.resource_id ,
                            am.appt_id ,
                            r.interval ,
                            rank_order = ROW_NUMBER() OVER ( PARTITION BY am.appt_id ORDER BY am.modify_timestamp DESC )
                  FROM      [10.183.0.94].NGProd.dbo.appointment_members am
                            INNER JOIN [10.183.0.94].NGProd.dbo.resources r ON am.resource_id = r.resource_id
                  WHERE     r.resource_type = 'Person'
                            AND am.delete_ind = 'N'
                ) x
        WHERE   rank_order = 1;

        CREATE INDEX ar_r ON #ar (resource_id);
        CREATE INDEX ar_a ON #ar (appt_id);

-- create staging table for data that will go into practice popup
        CREATE TABLE #d
            (
              appt_date VARCHAR(8) ,
              enc_date VARCHAR(8) ,
              begintime VARCHAR(4) ,
              res_id VARCHAR(36) ,
              appt_loc_id VARCHAR(36) ,
              enc_uid VARCHAR(36) ,
              enc_nbr BIGINT ,
              appt_nbr BIGINT ,
              appt_duration INT ,
              slot_time VARCHAR(4) ,
              enc_slot_nbr INT ,
              enc_slot_type VARCHAR(25)
            );

        CREATE TABLE #x
            (
              appt_date VARCHAR(8) ,
              begintime VARCHAR(4) ,
              resource_id VARCHAR(36) ,
              appt_loc_id VARCHAR(36) ,
              enc_uid VARCHAR(36) ,
              enc_nbr DECIMAL(12, 0) ,
              enc_date VARCHAR(8) ,
              appt_nbr DECIMAL(12, 0) ,
              slot_interval INT ,
              duration INT ,
              slot_count INT ,
              enc_loc_name VARCHAR(40) ,
              enc_loc_id VARCHAR(36) ,
              enc_rendering_name VARCHAR(75) ,
              enc_rendering_id VARCHAR(36) ,
              appt_type CHAR(1) ,
              appt_status CHAR(1) ,
              cancel_ind CHAR(1) ,
              delete_ind CHAR(1) ,
              resched_ind CHAR(1)
            );

-- all appts
        INSERT  INTO #x
                ( appt_date ,
                  begintime ,
                  resource_id ,
                  appt_loc_id ,
                  enc_uid ,
                  enc_nbr ,
                  appt_nbr ,
                  slot_interval ,
                  duration ,
                  slot_count ,
                  enc_loc_name ,
                  enc_loc_id ,
                  enc_date ,
                  enc_rendering_name ,
                  enc_rendering_id ,
                  appt_type ,
                  appt_status ,
                  cancel_ind ,
                  delete_ind ,
                  resched_ind
                )
                SELECT  a.appt_date ,
                        a.begintime ,
                        ar.resource_id ,
                        a.location_id ,
                        enc.enc_id ,
                        enc.enc_nbr ,
                        a.appt_nbr ,
                        ar.interval ,
                        a.duration ,
                        slot_count = FLOOR(a.duration / ar.interval) ,
                        enc_loc_name = ISNULL(loc.location_name, '') ,
                        enc_loc_id = loc.location_id ,
                        enc_date = CONVERT(VARCHAR(8), enc.billable_timestamp, 112) ,
                        enc_rendering_name = prov.description ,
                        enc_rendering_id = prov.provider_id ,
                        a.appt_type ,
                        a.appt_status ,
                        a.cancel_ind ,
                        a.delete_ind ,
                        a.resched_ind
                FROM    [10.183.0.94].NGProd.dbo.appointments a
                        INNER JOIN #ar ar ON a.appt_id = ar.appt_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter enc ON a.enc_id = enc.enc_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON enc.location_id = loc.location_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.provider_mstr prov ON enc.rendering_provider_id = prov.provider_id
--where a.appt_date between @dt_start and CONVERT(char(8), GETDATE(), 112)
                WHERE   a.appt_date >= @dt_start; 

/* 
-- 20140113  include future appts in 1st query, this becomes redundant
-- 20130415  add in future appts
insert into #x (appt_date, begintime, resource_id, appt_loc_id
  ,enc_uid, enc_nbr, appt_nbr, slot_interval, duration
  ,slot_count, enc_loc_name, enc_loc_id, enc_date
  ,enc_rendering_name, enc_rendering_id, appt_type, appt_status
  ,cancel_ind, delete_ind, resched_ind)
select
  a.appt_date
  ,a.begintime
  ,ar.resource_id
  ,a.location_id
  ,enc.enc_id
  ,enc.enc_nbr
  ,a.appt_nbr
  ,ar.interval
  ,a.duration
  ,slot_count = floor(a.duration/ar.interval)
  ,enc_loc_name = ISNULL(loc.location_name, '')
  ,enc_loc_id = loc.location_id
  ,enc_date = CONVERT(varchar(8), enc.billable_timestamp, 112)
  ,enc_rendering_name = prov.description
  ,enc_rendering_id = prov.provider_id
  ,a.appt_type
  ,a.appt_status
  ,a.cancel_ind
  ,a.delete_ind
  ,a.resched_ind
from [10.183.0.94].NGPROD.dbo.appointments a
  inner join #ar ar
    on a.appt_id = ar.appt_id
  left join [10.183.0.94].NGPROD.dbo.patient_encounter enc
    on a.enc_id = enc.enc_id
  left join [10.183.0.94].NGPROD.dbo.location_mstr loc
    on enc.location_id = loc.location_id
  left join [10.183.0.94].NGPROD.dbo.provider_mstr prov
    on enc.rendering_provider_id = prov.provider_id
where a.appt_date > CONVERT(char(8), GETDATE(), 112)
*/

-- add in past encounters not linked to appts
        INSERT  INTO #x
                ( appt_date ,
                  begintime ,
                  resource_id ,
                  appt_loc_id ,
                  enc_uid ,
                  enc_nbr ,
                  appt_nbr ,
                  slot_interval ,
                  duration ,
                  slot_count ,
                  enc_loc_name ,
                  enc_loc_id ,
                  enc_date ,
                  enc_rendering_name ,
                  enc_rendering_id ,
                  appt_type ,
                  appt_status ,
                  cancel_ind ,
                  delete_ind ,
                  resched_ind
                )
                SELECT  NULL AS appt_date ,
                        NULL AS begintime ,
                        NULL AS resource_id ,
                        NULL AS location_id ,
                        enc.enc_id ,
                        enc.enc_nbr ,
                        NULL AS appt_nbr ,
                        NULL AS interval ,
                        NULL AS duration ,
                        slot_count = NULL ,
                        enc_loc_name = ISNULL(loc.location_name, '') ,
                        enc_loc_id = loc.location_id ,
                        enc_date = CONVERT(VARCHAR(8), enc.billable_timestamp, 112) ,
                        enc_rendering_name = prov.description ,
                        enc_rendering_id = prov.provider_id ,
                        NULL AS appt_type ,
                        NULL AS appt_status ,
                        NULL AS cancel_ind ,
                        NULL AS delete_ind ,
                        NULL AS resched_ind
                FROM    [10.183.0.94].NGProd.dbo.patient_encounter enc
                        LEFT JOIN [10.183.0.94].NGProd.dbo.appointments a ON enc.enc_id = a.enc_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON enc.location_id = loc.location_id
                        LEFT JOIN [10.183.0.94].NGProd.dbo.provider_mstr prov ON enc.rendering_provider_id = prov.provider_id
                WHERE   a.enc_id IS NULL
                        AND CONVERT(CHAR(8), enc.billable_timestamp, 112) >= @dt_start; 


-- insert first slot
        INSERT  INTO #d
                ( appt_date ,
                  begintime ,
                  res_id ,
                  appt_loc_id ,
                  enc_uid ,
                  enc_nbr ,
                  appt_nbr ,
                  slot_time ,
                  appt_duration ,
                  enc_slot_nbr ,
                  enc_slot_type ,
                  enc_date
                )
                SELECT  appt_date ,
                        begintime ,
                        res_id = CAST(resource_id AS VARCHAR(36)) ,
                        appt_loc_id = CAST(x.appt_loc_id AS VARCHAR(36)) ,
                        enc_uid = CAST(x.enc_uid AS VARCHAR(36)) ,
                        enc_nbr ,
                        appt_nbr ,
                        slot_time = begintime ,
                        appt_duration = duration ,
                        enc_slot_nbr = 1 ,
                        enc_slot_type = CASE WHEN ISNULL(x.enc_uid, '') = '' THEN 'Appt start'
                                             ELSE 'Enc start'
                                        END ,
                        x.enc_date
                FROM    #x x
                WHERE   ISNULL(slot_count, 0) > 0;

-- set limit
        SELECT  @x = MAX(slot_count)
        FROM    #x;
        SET @i = 2;
        WHILE @i <= @x
            BEGIN
                INSERT  INTO #d
                        ( appt_date ,
                          begintime ,
                          res_id ,
                          appt_loc_id ,
                          enc_uid ,
                          enc_nbr ,
                          appt_nbr ,
                          slot_time ,
                          appt_duration ,
                          enc_slot_nbr ,
                          enc_slot_type ,
                          enc_date
                        )
                        SELECT  appt_date ,
                                begintime ,
                                res_id = CAST(resource_id AS VARCHAR(36)) ,
                                appt_loc_id = CAST(x.appt_loc_id AS VARCHAR(36)) ,
                                enc_uid = CAST(x.enc_uid AS VARCHAR(36)) ,
                                enc_nbr ,
                                appt_nbr ,
                                slot_time = REPLACE(LEFT(CONVERT(VARCHAR(10), DATEADD(MI, x.slot_interval * ( @i - 1 ),
                                                                                      CAST('20120101 '
                                                                                      + LEFT(x.begintime, 2) + ':'
                                                                                      + RIGHT(x.begintime, 2) AS DATETIME)), 108),
                                                         5), ':', '') ,
                                appt_duration = duration ,
                                enc_slot_nbr = @i ,
                                enc_slot_type = CASE WHEN ISNULL(x.enc_uid, '') = '' THEN 'Appt continuing'
                                                     ELSE 'Enc continuing'
                                                END ,
                                x.enc_date
                        FROM    #x x
                        WHERE   slot_count >= @i;
  
                SET @i = @i + 1;
            END; 

-- now have to bring in enc w no appt info
        INSERT  INTO #d
                ( appt_date ,
                  begintime ,
                  res_id ,
                  appt_loc_id ,
                  enc_uid ,
                  enc_nbr ,
                  appt_nbr ,
                  slot_time ,
                  appt_duration ,
                  enc_slot_nbr ,
                  enc_slot_type ,
                  enc_date
                )
                SELECT  appt_date ,
                        begintime ,
                        res_id = CAST(resource_id AS VARCHAR(36)) ,
                        appt_loc_id = CAST(x.appt_loc_id AS VARCHAR(36)) ,
                        enc_uid = CAST(x.enc_uid AS VARCHAR(36)) ,
                        enc_nbr ,
                        appt_nbr ,
                        slot_time = begintime ,
                        appt_duration = duration ,
                        enc_slot_nbr = 1 ,
                        enc_slot_type = 'Enc no appt' ,
                        x.enc_date
                FROM    #x x
                WHERE   ISNULL(slot_count, 0) = 0;

/*

drop table #ar
drop table #d
drop table #x

*/

--delete from [10.183.0.94].NGPROD.dbo.chcn_ccb_enc_w_appts_ep_
--where appt_date >= @dt_start

/*insert into [10.183.0.94].NGPROD.dbo.chcn_ccb_enc_w_appts_ep_
  (seq_no, practice_id, created_by, create_timestamp, 
  modified_by, modify_timestamp,
  appt_date, begintime, res_id, appt_loc_id, 
  enc_uid, enc_nbr, appt_nbr, appt_duration, 
  resource_interval, enc_loc_name, enc_loc_id, 
  enc_rendering_name, enc_rendering_id, appt_type, 
  appt_status, appt_slot_start_ind, appt_slot_info, 
  appt_slot_nbr, slot_time, appt_kept_ind, 
  appt_cancel_ind, appt_resched_ind, appt_delete_ind
  ,enc_date)
*/




        SELECT  NEWID() AS Appt_new_key ,
                @prac_id AS Practice_id ,
                @u AS created_by ,
                @t AS create_timestamp ,
                @u AS modified_by ,
                @t AS modify_timestamp ,
                d.appt_date ,
                d.begintime ,
                d.res_id ,
                d.appt_loc_id ,
                d.enc_uid ,
                d.enc_nbr ,
                d.appt_nbr ,
                d.appt_duration ,
                r.interval
--  ,enc_loc_name = loc.location_name
                ,
                enc_loc_id = loc.location_id
 -- ,enc_rendering_name = prov.description
                ,
                enc_rendering_id = enc.rendering_provider_id ,
                a.appt_type ,
                a.appt_status ,
                start_ind = d.enc_slot_type ,
                slot_info = CAST(d.enc_slot_nbr AS VARCHAR(2)) + ' of '
                + CAST(FLOOR(d.appt_duration / r.interval) AS VARCHAR(2)) ,
                d.enc_slot_nbr ,
                d.slot_time ,
                a.appt_kept_ind ,
                a.cancel_ind ,
                a.resched_ind ,
                a.delete_ind ,
                d.enc_date ,
                enc.checkin_datetime
 -- ,enc.checkout_datetime
                ,
                enc.enc_status  -- Open?
                ,
                CASE WHEN ( d.enc_slot_nbr = 1
                            AND d.appt_date IS NOT NULL
                            AND d.begintime IS NOT NULL
                          )
                     THEN DATEDIFF(mi,
                                   CAST(CONCAT(SUBSTRING(d.appt_date, 1, 4), '/', SUBSTRING(d.appt_date, 5, 2), '/',
                                               SUBSTRING(d.appt_date, 7, 2), ' ', SUBSTRING(d.begintime, 1, 2), ':',
                                               SUBSTRING(d.begintime, 3, 2), ':00') AS DATETIME), enc.checkin_datetime)
                END Cycle_Min_slottime_to_Kept ,
                per.primarycare_prov_id ,
                a.appt_id ,
                a.event_id ,
                a.person_id AS app_person_id ,
                enc.person_id AS enc_person_id ,
                ISNULL(a.person_id, enc.person_id) AS person_id ,
                a.cancel_reason ,
                a.resched_reason ,
                a.create_timestamp AS appt_made_when ,
                a.created_by AS appt_made_by ,
                a.workflow_status ,
                a.workflow_room ,
                CASE WHEN ( d.enc_slot_nbr = 1
                            AND a.person_id IS NOT NULL
                            AND per.primarycare_prov_id = enc.rendering_provider_id
                          ) THEN 'PCP Visit'
                     WHEN ( a.person_id IS NULL ) THEN 'No Patient attached to Appointment or No appointment'
                     ELSE 'Not booked with PCP'
                END AS Apt_By_PCP ,
                CASE WHEN ( (d.enc_slot_nbr = 1
                            AND a.person_id IS NULL )
                          ) THEN 1
                     ELSE 0
                END AS Apt_notlinked_toPerson ,
                CASE WHEN ( d.enc_slot_nbr = 1
                            AND a.person_id IS NOT NULL
                            AND per.primarycare_prov_id = enc.rendering_provider_id
                          ) THEN 1
                     ELSE 0
                END AS Nbr_PCP_Appt ,
                CASE WHEN ( d.enc_slot_nbr = 1
                            AND a.person_id IS NOT NULL
                            AND per.primarycare_prov_id != enc.rendering_provider_id
                          ) THEN 1
                     ELSE 0
                END AS Nbr_NonPCP_Appt ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.appt_kept_ind = 'Y'
                          AND ISNULL(a.appt_type, 'x') <> 'D'
                          AND enc.enc_id IS NOT NULL THEN 1
                     ELSE 0
                END AS nbr_kept_and_linked_enc ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.appt_date > CONVERT(CHAR(8), GETDATE(), 112)
                          AND a.delete_ind = 'N'
                          AND a.cancel_ind = 'N'
                          AND a.resched_ind = 'N'
                          AND ISNULL(a.appt_type, 'x') <> 'D' THEN 1
                     ELSE 0
                END AS nbr_future ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.appt_kept_ind = 'Y'
                          AND ISNULL(a.appt_type, 'x') <> 'D'
                          AND enc.enc_id IS NULL THEN 1
                     ELSE 0
                END AS nbr_kept_not_linked_enc ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND ISNULL(a.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(a.cancel_ind, 'N') = 'N'
                          AND ISNULL(a.delete_ind, 'N') = 'N'
                          AND ISNULL(a.resched_ind, 'N') = 'N'
                          AND a.appt_date <= CONVERT(CHAR(8), GETDATE(), 112) THEN 1
                     ELSE 0
                END AS nbr_no_show ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.cancel_ind = 'Y'
                          AND a.resched_ind = 'N' THEN 1
                     ELSE 0
                END AS nbr_cancelled ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.delete_ind = 'Y'
                          AND a.resched_ind = 'N' THEN 1
                     ELSE 0
                END AS nbr_deleted ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.resched_ind = 'Y' THEN 1
                     ELSE 0
                END AS nbr_rescheduled ,
                a.duration AS slot_dur_appt_records ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.appt_kept_ind = 'Y'
                          AND enc.enc_id IS NOT NULL THEN a.duration
                     ELSE 0
                END AS slot_dur_kept_and_linked_enc ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.appt_date > CONVERT(CHAR(8), GETDATE(), 112)
                          AND a.delete_ind = 'N'
                          AND a.cancel_ind = 'N'
                          AND a.resched_ind = 'N' THEN a.duration
                     ELSE 0
                END AS slot_dur_future ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.appt_kept_ind = 'Y'
                          AND enc.enc_id IS NULL THEN a.duration
                     ELSE 0
                END AS slot_dur_kept_not_linked_enc ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND ISNULL(a.appt_kept_ind, 'N') = 'N'
                          AND ISNULL(a.cancel_ind, 'N') = 'N'
                          AND ISNULL(a.delete_ind, 'N') = 'N'
                          AND ISNULL(a.resched_ind, 'N') = 'N'
                          AND a.appt_date <= CONVERT(CHAR(8), GETDATE(), 112) THEN a.duration
                     ELSE 0
                END AS slot_dur_no_show ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.cancel_ind = 'Y' THEN a.duration
                     ELSE 0
                END AS slot_dur_cancelled ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.delete_ind = 'Y' THEN a.duration
                     ELSE 0
                END AS slot_dur_deleted ,
                CASE WHEN d.enc_slot_nbr = 1
                          AND a.resched_ind = 'Y' THEN a.duration
                     ELSE 0
                END AS slot_dur_rescheduled ,
                ( CASE WHEN d.enc_slot_nbr = 1
                            AND enc.billable_ind = 'Y'
                            AND a.enc_id IS NOT NULL THEN 1
                       ELSE 0
                  END ) AS nbr_bill_w_appt ,
                ( CASE WHEN d.enc_slot_nbr = 1
                            AND enc.billable_ind != 'Y'
                            AND a.enc_id IS NOT NULL THEN 1
                       ELSE 0
                  END ) AS nbr_non_bill_w_appt ,
                ( CASE WHEN d.enc_slot_nbr = 1
                            AND enc.billable_ind = 'Y'
                            AND a.enc_id IS NOT NULL THEN a.duration
                       ELSE 0
                  END ) AS enc_billable_linked_appt_dur_mins ,
                ( CASE WHEN d.enc_slot_nbr = 1
                            AND enc.billable_ind = 'N'
                            AND a.enc_id IS NOT NULL THEN a.duration
                       ELSE 0
                  END ) AS enc_non_billable_linked_appt_dur_mins ,
                st1.created_by AS User_Checkout_MA ,
                st1.Min_Kept_to_StatusUpdate AS Cycle_Min_Kept_CheckedOut ,
                st2.created_by AS User_ReadyforProvider_MA ,
                st2.Min_Kept_to_StatusUpdate AS Cycle_Min_Kept_ReadyForProvider ,
                st3.Min_Kept_to_StatusUpdate AS Cycle_Min_Kept_Charted ,
                st4.Min_Since_last_StatusUpdate Cycle_Min_ReadyforProvider_Checkout ,
                enc.created_by AS user_created_Encounter
        INTO    dwh.data_appointment
        FROM    #d d
                LEFT JOIN [10.183.0.94].NGProd.dbo.resources r ON d.res_id = CAST(r.resource_id AS VARCHAR(36))
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient_encounter enc ON d.enc_uid = CAST(enc.enc_id AS VARCHAR(36))
                LEFT JOIN ( SELECT  [enc_id] ,
                                    [created_by] ,
                                    [Min_Since_last_StatusUpdate] ,
                                    [Min_Kept_to_StatusUpdate]
                            FROM    [Staging_Ghost].[dbo].[staging_ng_status_data_]
                            WHERE   txt_status LIKE '%Checked-Out%'
                          ) st1 ON d.enc_uid = CAST(st1.enc_id AS VARCHAR(36))
                LEFT JOIN ( SELECT  [enc_id] ,
                                    [created_by] ,
                                    [Min_Since_last_StatusUpdate] ,
                                    [Min_Kept_to_StatusUpdate]
                            FROM    [Staging_Ghost].[dbo].[staging_ng_status_data_]
                            WHERE   txt_status LIKE '%Ready for Provider%'
                          ) st2 ON d.enc_uid = CAST(st2.enc_id AS VARCHAR(36))
                LEFT JOIN ( SELECT  [enc_id] ,
                                    [created_by] ,
                                    [Min_Since_last_StatusUpdate] ,
                                    [Min_Kept_to_StatusUpdate]
                            FROM    [Staging_Ghost].[dbo].[staging_ng_status_data_]
                            WHERE   txt_status LIKE '%CHARTED%'
                          ) st3 ON d.enc_uid = CAST(st3.enc_id AS VARCHAR(36))
                LEFT JOIN ( SELECT  [enc_id] ,
                                    [created_by] ,
                                    [Min_Since_last_StatusUpdate] ,
                                    [Min_Kept_to_StatusUpdate]
                            FROM    [Staging_Ghost].[dbo].[staging_ng_status_data_]
                            WHERE   txt_status LIKE '%Check-Out%'
                          ) st4 ON d.enc_uid = CAST(st4.enc_id AS VARCHAR(36))
                LEFT JOIN [10.183.0.94].NGProd.dbo.location_mstr loc ON enc.location_id = loc.location_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.provider_mstr prov ON enc.rendering_provider_id = prov.provider_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.appointments a ON d.appt_nbr = a.appt_nbr
                LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON per.person_id = enc.person_id;




        DROP TABLE #x;
        DROP TABLE #ar;
        DROP TABLE #d;
 

 

    END;
GO
