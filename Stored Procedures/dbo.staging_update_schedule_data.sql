SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_schedule_data]
	--
AS
BEGIN


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
 DECLARE @prac_id char(4)


SET @prac_id = '0001'
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.

SET NOCOUNT ON;

 -- Insert statements for procedure here
 DECLARE @dt_start varchar(8),
                   @dt_end varchar(8)

set @dt_start = CONVERT(varchar(8),GETDATE(),112) --This routine will build current and hx data from begin to end date 


--SET @dt_start = '20100301' 


 SET  @dt_end = (SELECT
  MAX(rt.week_end_date)
  FROM [10.183.0.94].[NGProd].[dbo].resource_templates rt)
 
 -- (SELECT convert(varchar(8), DATEADD(dd, 270 ,getdate()), 112)) 
 DECLARE @u int -- user id to use as the created by
 
 
 
 
 
 DECLARE @t datetime

SET @u =
  (SELECT user_id
   FROM [10.183.0.94].[NGProd].[dbo].user_mstr
   WHERE login_id= 'autoupdate') IF @u IS NULL
SET @u = 0
SET @t = GETDATE() DECLARE @dt_inc varchar(8)
SET @dt_inc = @dt_start -- dt_inc = incrementer

DELETE
FROM  [dbo].[staging_ng_schedule_data_] 
WHERE slot_date BETWEEN @dt_start AND @dt_end while @dt_inc <= @dt_end BEGIN
  SELECT DISTINCT provider_name = prov.description ,
                  provider_id = prov.provider_id ,
                  resource_name = r.description ,
                  resource_id = r.resource_id ,
                  appt_template_name = t.template ,
                  appt_template_id = t.appt_template_id ,
                  appt_template_interval = t.interval ,
                  appt_template_daily_ind = t.daily_template_ind ,
                  appt_template_exception_ind = t.exception_ind ,
                  rt.week_start_date ,
                  tm.day ,
                  slot_date = @dt_inc ,
                  tm.begintime ,
                  tm.endtime ,
                  tm.duration --,loc.location_name
 --,loc.location_id

                             ,
                             c.prevent_appts_ind ,
                             cm.category_desc ,
                             cm.category_id ,
                             cm.working_ind ,
                             cm.patients_ind ,
                             cm.appts_ind ,
                             rpt_week = convert(varchar(8), DATEADD(dd, 7-datepart(dw, @dt_inc), @dt_inc), 112) ,
                                        rpt_mon = LEFT(@dt_inc,6) ,
                                                  ast.overbook_limit INTO #t
  FROM [10.183.0.94].[NGProd].[dbo].resources r
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].provider_mstr prov ON r.phys_id = prov.provider_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].resource_templates rt ON r.resource_id = rt.resource_id
  AND r.practice_id = rt.practice_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_templates t ON rt.appt_template_id = t.appt_template_id
  AND rt.practice_id = t.practice_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].template_members tm ON t.appt_template_id = tm.appt_template_id
  AND t.practice_id = tm.practice_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].categories c ON tm.category_id = c.category_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].chcn_category_type_map_ep_ cm ON tm.category_id = cm.category_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_slot_templates ast ON ast.practice_id = t.practice_id
  AND ast.appt_template_id = t.appt_template_id
  AND ast.day = tm.day
  AND ast.begintime = tm.begintime WHERE @dt_inc BETWEEN rt.week_start_date AND rt.week_end_date
  AND r.practice_id = @prac_id
  AND tm.day IN (0,
                 DATEPART(dw, cast(@dt_inc AS datetime))) -- insert records, expanding multi-slot durations
 DECLARE @i int, @z int
  SET @i = 1
  SET @z =
    (SELECT MAX(duration/appt_template_interval)
     FROM #t) while @i <= @z BEGIN
  INSERT INTO  [dbo].[staging_ng_schedule_data_]  (seq_no, practice_id, created_by, create_timestamp, modified_by, modify_timestamp, resource_name, resource_id, provider_name, provider_id, slot_category, slot_category_id, prevent_appts_ind, working_ind, patients_ind, appts_ind, location_name, location_id, slot_begin_time, slot_end_time, slot_duration, slot_date, rpt_week, rpt_mon, appt_template_name, appt_template_id, daily_template_ind, exception_ind)
  SELECT NEWID() ,@prac_id ,@u, @t, @u, @t ,
                                         resource_name ,
                                         resource_id ,
                                         provider_name ,
                                         provider_id ,
                                         category_desc ,
                                         category_id ,
                                         prevent_appts_ind ,
                                         working_ind ,
                                         patients_ind ,
                                         appts_ind ,
                                         NULL --location_name

                                             ,
                                             NULL --location_id

                                                 ,
                                                 begintime = replace(left(CONVERT(varchar(20), DATEADD(mi, 15*(@i-1), CAST(@dt_inc + ' ' + LEFT(begintime,2) + ':' + RIGHT(begintime,2) AS datetime)), 114),5),':', '') ,
                                                             endtime ,
                                                             duration = appt_template_interval ,
                                                             slot_date ,
                                                             rpt_week ,
                                                             rpt_mon ,
                                                             appt_template_name ,
                                                             appt_template_id ,
                                                             appt_template_daily_ind ,
                                                             appt_template_exception_ind
  FROM #t WHERE duration/appt_template_interval >= @i
  SET @i = @i + 1 END
  DROP TABLE #t
  SET @dt_inc =
    (SELECT convert(varchar(8), DATEADD(dd, 1, cast(@dt_inc AS datetime)), 112)) END -- now update location info

  UPDATE d
  SET d.location_id = tl.location_id ,
      d.location_name = loc.location_name
  FROM  [dbo].[staging_ng_schedule_data_]  d
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].template_locations tl ON d.appt_template_id = tl.appt_template_id
  AND (DATEPART(dw, cast(d.slot_date AS datetime)) = tl.day
       OR tl.day = 0)
  AND d.slot_begin_time BETWEEN tl.begintime AND tl.endtime
  AND d.practice_id = tl.practice_id
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].location_mstr loc ON tl.location_id = loc.location_id -- add in date filter
WHERE d.slot_date BETWEEN @dt_start AND @dt_end
  UPDATE SD
  SET slot_date_dt = cast(sd.slot_date AS date) ,
                     prov_res_name = ISNULL(sd.provider_name,isnull(sd.resource_name,'')) ,
                                     prov_res_id = isnull(sd.provider_id, sd.resource_id) ,
                                                   prov_res_ind = CASE
                                                                      WHEN sd.provider_id IS NULL THEN 'R'
                                                                      ELSE 'P'
                                                                  END ,
                                                                  category_group = cmp.group1 ,
                                                                  sched_min_tot_dur = sd.slot_duration ,
                                                                  sched_min_working_dur = CASE
                                                                                              WHEN sd.working_ind = 'Yes' THEN sd.slot_duration
                                                                                              ELSE 0
                                                                                          END ,
                                                                                          sched_min_patients_dur = CASE
                                                                                                                       WHEN sd.patients_ind = 'Yes' THEN sd.slot_duration
                                                                                                                       ELSE 0
                                                                                                                   END ,
                                                                                                                   sched_min_no_appts_dur = CASE
                                                                                                                                                WHEN sd.appts_ind = 'No' THEN sd.slot_duration
                                                                                                                                                ELSE 0
                                                                                                                                            END ,
                                                                                                                                            sched_hrs_tot_dur = CAST(isnull(sched_min_tot_dur ,0) AS numeric(12,2))/60 ,
                                                                                                                                            sched_hrs_working_dur = CAST(isnull(sched_min_working_dur,0) AS numeric(12,2))/60 ,
                                                                                                                                            sched_hrs_clinical_dur = CAST(isnull(sched_min_patients_dur,0) AS numeric(12,2))/60 ,
                                                                                                                                            sched_hrs_no_appts_dur = CAST(isnull(sched_min_no_appts_dur ,0) AS numeric(12,2))/60
  FROM  [dbo].[staging_ng_schedule_data_]  sd
  LEFT JOIN [10.183.0.94].[NGProd].[dbo].chcn_category_type_map_ep_ cmp ON sd.slot_category_id = cmp.category_id WHERE sd.slot_date BETWEEN CONVERT(char(8), @dt_start, 112) AND CONVERT(char(8), @dt_end, 112)
  UPDATE SD
  SET sched_hrs_tot_dur = CAST(isnull(sched_min_tot_dur ,0) AS numeric(12,2))/60 ,
      sched_hrs_working_dur = CAST(isnull(sched_min_working_dur,0) AS numeric(12,2))/60 ,
      sched_hrs_clinical_dur = CAST(isnull(sched_min_patients_dur,0) AS numeric(12,2))/60 ,
      sched_hrs_no_appts_dur = CAST(isnull(sched_min_no_appts_dur ,0) AS numeric(12,2))/60
  FROM  [dbo].[staging_ng_schedule_data_]  sd


/*
create index sd_sd on dbo.staging_ng_schedule_data_  (slot_date)


create index sd_sdt on dbo.staging_ng_schedule_data_  (slot_date_dt)

create index sd_bt on dbo.staging_ng_schedule_data_  (slot_begin_time)

create index sd_locid on dbo.staging_ng_schedule_data_  (location_id)

*/





END

GO
