SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_appointment_data]
AS
BEGIN




declare @dys_back int

declare @prac_id char(4)

set @dys_back = 2190
set @prac_id = '0001'


  -- get auto update user id
  declare @u int
  set @u = (select USER_ID from [10.183.0.94].NGPROD.dbo.user_mstr
    where first_name = 'AutoUpdate' 
      )
  if @u is null set @u = 0
      
  -- set time var
  declare @t datetime
  set @t = GETDATE()



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
declare @dt_start varchar(8)
select @dt_start = '20100301' 
declare @x int
declare @i int

--DELETE
--FROM [10.183.0.94].NGPROD.dbo.chcn_ccb_enc_w_appts_ep_
--where appt_date >= @dt_start
 -- or enc_date >= @dt_start


-- use last modified person resource to deal with any multi-resource appts
select
  resource_id
  ,appt_id
  ,interval
into #ar
from (
	select
		am.resource_id
		,am.appt_id
		,r.interval
		,rank_order = ROW_NUMBER() over (
			partition by am.appt_id
			order by am.modify_timestamp desc
			)
	from [10.183.0.94].NGPROD.dbo.appointment_members am
		inner join [10.183.0.94].NGPROD.dbo.resources r
			on am.resource_id = r.resource_id
	where r.resource_type = 'Person'
		and am.delete_ind = 'N'
) x
where rank_order = 1

create index ar_r on #ar (resource_id)
create index ar_a on #ar (appt_id)

-- create staging table for data that will go into practice popup
create table #d (
  appt_date varchar(8)
  ,enc_date varchar(8)
  ,begintime varchar(4)
  ,res_id varchar(36)
  ,appt_loc_id varchar(36)
  ,enc_uid varchar(36)
  ,enc_nbr bigint
  ,appt_nbr bigint
  ,appt_duration int
  ,slot_time varchar(4)
  ,enc_slot_nbr int
  ,enc_slot_type varchar(25)
  )

create table #x (
  appt_date varchar(8)
  ,begintime varchar(4)
  ,resource_id varchar(36)
  ,appt_loc_id varchar(36)
  ,enc_uid varchar(36)
  ,enc_nbr decimal(12,0)
  ,enc_date varchar(8)
  ,appt_nbr decimal(12,0)
  ,slot_interval int
  ,duration int
  ,slot_count int
  ,enc_loc_name varchar(40)
  ,enc_loc_id varchar(36)
  ,enc_rendering_name varchar(75)
  ,enc_rendering_id varchar(36)
  ,appt_type char(1)
  ,appt_status char(1)
  ,cancel_ind char(1)
  ,delete_ind char(1)
  ,resched_ind char(1)
  )

-- all appts
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
--where a.appt_date between @dt_start and CONVERT(char(8), GETDATE(), 112)
where a.appt_date >= @dt_start 

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
insert into #x (appt_date, begintime, resource_id, appt_loc_id
  ,enc_uid, enc_nbr, appt_nbr, slot_interval, duration
  ,slot_count, enc_loc_name, enc_loc_id, enc_date
  ,enc_rendering_name, enc_rendering_id, appt_type, appt_status
  ,cancel_ind, delete_ind, resched_ind)
select
  NULL as appt_date
  ,NULL as begintime
  ,NULL as resource_id
  ,NULL as location_id
  ,enc.enc_id
  ,enc.enc_nbr
  ,NULL as appt_nbr
  ,NULL as interval
  ,NULL as duration
  ,slot_count = NULL
  ,enc_loc_name = ISNULL(loc.location_name, '')
  ,enc_loc_id = loc.location_id
  ,enc_date = CONVERT(varchar(8), enc.billable_timestamp, 112)
  ,enc_rendering_name = prov.description
  ,enc_rendering_id = prov.provider_id
  ,NULL as appt_type
  ,NULL as appt_status
  ,NULL as cancel_ind
  ,NULL as delete_ind
  ,NULL as resched_ind
from [10.183.0.94].NGPROD.dbo.patient_encounter enc 
  left join [10.183.0.94].NGPROD.dbo.appointments a
    on enc.enc_id = a.enc_id
  left join [10.183.0.94].NGPROD.dbo.location_mstr loc
    on enc.location_id = loc.location_id
  left join [10.183.0.94].NGPROD.dbo.provider_mstr prov
    on enc.rendering_provider_id = prov.provider_id
where a.enc_id is null
  and CONVERT(char(8), enc.billable_timestamp, 112) >= @dt_start 


-- insert first slot
insert into #d (appt_date, begintime, res_id,
  appt_loc_id, enc_uid, enc_nbr, appt_nbr,
  slot_time, appt_duration, enc_slot_nbr, enc_slot_type
  ,enc_date)
select 
  appt_date
  ,begintime
  ,res_id = CAST(resource_id as varchar(36))
  ,appt_loc_id = CAST(x.appt_loc_id as varchar(36))
  ,enc_uid = CAST(x.enc_uid as varchar(36))
  ,enc_nbr
  ,appt_nbr
  ,slot_time = begintime
  ,appt_duration = duration 
  ,enc_slot_nbr = 1
  ,enc_slot_type = CASE WHEN isnull(x.enc_uid,'') = ''
    then 'Appt start' ELSE 'Enc start' END
  ,x.enc_date
from #x x
where isnull(slot_count,0) > 0

-- set limit
select @x = MAX(slot_count) from #x
set @i = 2
while @i <= @x
begin
	insert into #d (appt_date, begintime, res_id,
		appt_loc_id, enc_uid, enc_nbr, appt_nbr,
		slot_time, appt_duration, enc_slot_nbr, enc_slot_type
		,enc_date)
	select 
		appt_date
		,begintime
		,res_id = CAST(resource_id as varchar(36))
		,appt_loc_id = CAST(x.appt_loc_id as varchar(36))
		,enc_uid = CAST(x.enc_uid as varchar(36))
		,enc_nbr
		,appt_nbr
  	,slot_time = replace(left(CONVERT(varchar(10), dateadd(MI, x.slot_interval *(@i-1),
			cast('20120101 ' + LEFT(x.begintime,2) + ':' + RIGHT(x.begintime,2) as datetime)), 
			108),5),':','')
		,appt_duration = duration 
		,enc_slot_nbr = @i
		,enc_slot_type = CASE WHEN isnull(x.enc_uid,'') = ''
    then 'Appt continuing' ELSE 'Enc continuing' END
		,x.enc_date
	from #x x
	where slot_count >= @i
  
  set @i = @i + 1
end 

-- now have to bring in enc w no appt info
insert into #d (appt_date, begintime, res_id,
  appt_loc_id, enc_uid, enc_nbr, appt_nbr,
  slot_time, appt_duration, enc_slot_nbr, enc_slot_type
  ,enc_date)
select 
  appt_date
  ,begintime
  ,res_id = CAST(resource_id as varchar(36))
  ,appt_loc_id = CAST(x.appt_loc_id as varchar(36))
  ,enc_uid = CAST(x.enc_uid as varchar(36))
  ,enc_nbr
  ,appt_nbr
  ,slot_time = begintime
  ,appt_duration = duration 
  ,enc_slot_nbr = 1
  ,enc_slot_type = 'Enc no appt'
  ,x.enc_date
from #x x
where isnull(slot_count,0) = 0

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




IF OBJECT_ID('staging_ng_appointment_data_') IS NOT NULL DROP TABLE staging_ng_appointment_data_

select 
  NEWID() as Appt_new_key, 
  @prac_id as Practice_id,
   @u as created_by ,
    @t as create_timestamp,
	 @u as modified_by,
	  @t as modify_timestamp
  ,d.appt_date 
  ,d.begintime 
  ,d.res_id
  ,d.appt_loc_id 
  ,d.enc_uid 
  ,d.enc_nbr 
  ,d.appt_nbr 
  ,d.appt_duration 
  ,r.interval
  ,enc_loc_name = loc.location_name
  ,enc_loc_id = loc.location_id
  ,enc_rendering_name = prov.description
  ,enc_rendering_id = enc.rendering_provider_id
  ,a.appt_type
  ,a.appt_status
  ,start_ind = d.enc_slot_type 
  ,slot_info = CAST(d.enc_slot_nbr as varchar(2)) + ' of ' +
    CAST(floor(d.appt_duration/r.interval) as varchar(2)) 
  ,d.enc_slot_nbr 
  ,d.slot_time
  ,a.appt_kept_ind
  ,a.cancel_ind
  ,a.resched_ind
  ,a.delete_ind
  ,d.enc_date
  ,enc.checkin_datetime
 -- ,enc.checkout_datetime
   ,enc.enc_status  -- Open?
     ,case when (d.enc_slot_nbr =1 and d.appt_date is not null and d.begintime is not null ) then
 	 datediff(mi,cast( concat(substring(d.appt_date,1,4), '/',substring(d.appt_date,5,2),'/',substring(d.appt_date,7,2), ' ', 
	 substring(d.begintime,1,2),':', substring(d.begintime,3,2),':00') as datetime),enc.checkin_datetime ) end Cycle_Min_slottime_to_Kept




  ,per.primarycare_prov_id
       ,a.appt_id
      ,a.event_id
      ,a.person_id as app_person_id
	  ,enc.person_id as enc_person_id
	  ,isnull (a.person_id ,enc.person_id )  as person_id
      ,a.cancel_reason
      ,a.resched_reason

      ,a.create_timestamp as appt_made_when
      ,a.created_by as appt_made_by
      ,a.workflow_status
      ,a.workflow_room
      
	  
	  
	  
	  
	  
	  
	  
	  ,case when (d.enc_slot_nbr =1 and a.person_id is not null  and per.primarycare_prov_id = enc.rendering_provider_id) then 'PCP Visit' 
	  when 
	  (a.person_id is null )  then 'No Patient attached to Appointment or No appointment' 
	   
	  else 'Not booked with PCP' end as Apt_By_PCP,

	  case when 
	  ((d.enc_slot_nbr =1 and a.person_id is null ))  then 1
	   
	  else 0 end as Apt_notlinked_toPerson



	    ,case when 
	  
	  (d.enc_slot_nbr =1 and a.person_id is not null and per.primarycare_prov_id = enc.rendering_provider_id) then 1
	  
	  else 0 end as Nbr_PCP_Appt

	  ,case when 
	  
	  (d.enc_slot_nbr =1 and a.person_id is not null and per.primarycare_prov_id != enc.rendering_provider_id) then 1
		   
	  else 0 end as Nbr_NonPCP_Appt



 , case 
    when d.enc_slot_nbr =1 and a.appt_kept_ind = 'Y' and ISNULL(a.appt_type,'x') <> 'D'
      and enc.enc_id is not NULL
    then 1 else 0 END as nbr_kept_and_linked_enc
  ,CASE WHEN d.enc_slot_nbr =1 and a.appt_date > CONVERT(char(8), GETDATE(), 112) 
       and a.delete_ind = 'N' and a.cancel_ind = 'N' and a.resched_ind = 'N'
         and ISNULL(a.appt_type,'x') <> 'D'
       THEN 1 ELSE 0 end as nbr_future


  ,case 
    when d.enc_slot_nbr =1 and a.appt_kept_ind = 'Y' and ISNULL(a.appt_type,'x') <> 'D'
      and enc.enc_id is NULL
    then 1 else 0 END as nbr_kept_not_linked_enc
  ,CASE 
    when d.enc_slot_nbr =1 and  isnull(a.appt_kept_ind, 'N') = 'N'
      and isnull(a.cancel_ind, 'N') = 'N'
      and isnull(a.delete_ind, 'N') = 'N'
      and isnull(a.resched_ind, 'N') = 'N'
      and a.appt_date <= CONVERT(char(8), GETDATE(), 112)
    then 1 else 0 end as nbr_no_show
  ,CASE WHEN d.enc_slot_nbr =1 and a.cancel_ind = 'Y' and a.resched_ind = 'N'
    THEN 1 else 0 end as nbr_cancelled
  , CASE WHEN d.enc_slot_nbr =1 and a.delete_ind = 'Y' and a.resched_ind = 'N'
    THEN 1 else 0 end as nbr_deleted
  ,CASE WHEN d.enc_slot_nbr =1 and a.resched_ind = 'Y' THEN 1 else 0 end as nbr_rescheduled
  , a.duration as slot_dur_appt_records
  , case 
    when d.enc_slot_nbr =1 and a.appt_kept_ind = 'Y' and enc.enc_id is not NULL
    then a.duration else 0 END as slot_dur_kept_and_linked_enc
  ,CASE WHEN d.enc_slot_nbr =1 and a.appt_date > CONVERT(char(8), GETDATE(), 112) 
      and a.delete_ind = 'N' and a.cancel_ind = 'N' and a.resched_ind = 'N'
      THEN a.duration ELSE 0 end as slot_dur_future
  ,case 
    when d.enc_slot_nbr =1 and a.appt_kept_ind = 'Y' and enc.enc_id is NULL
    then a.duration else 0 END as slot_dur_kept_not_linked_enc
  ,CASE 
    when d.enc_slot_nbr =1 and isnull(a.appt_kept_ind, 'N') = 'N'
      and isnull(a.cancel_ind, 'N') = 'N'
      and isnull(a.delete_ind, 'N') = 'N'
      and isnull(a.resched_ind, 'N') = 'N'
      and a.appt_date <= CONVERT(char(8), GETDATE(), 112)
    then a.duration else 0 end as slot_dur_no_show
  , CASE WHEN d.enc_slot_nbr =1 and a.cancel_ind = 'Y' THEN a.duration else 0 end as slot_dur_cancelled
 , CASE WHEN d.enc_slot_nbr =1 and a.delete_ind = 'Y' THEN a.duration else 0 end as slot_dur_deleted
  ,CASE WHEN d.enc_slot_nbr =1 and a.resched_ind = 'Y' THEN a.duration else 0 end as slot_dur_rescheduled

  , (CASE 
      WHEN d.enc_slot_nbr =1 and enc.billable_ind = 'Y' and a.enc_id IS NOT NULL 
      THEN 1 ELSE 0 END ) as nbr_bill_w_appt

 
 
  ,(CASE 
      WHEN d.enc_slot_nbr =1 and enc.billable_ind != 'Y' and a.enc_id IS NOT NULL 
      THEN 1 ELSE 0 END ) as nbr_non_bill_w_appt
  

  , (CASE 
      WHEN d.enc_slot_nbr =1 and enc.billable_ind = 'Y' and a.enc_id IS NOT NULL 
      THEN a.duration ELSE 0 END ) as enc_billable_linked_appt_dur_mins
  ,(CASE 
      WHEN d.enc_slot_nbr =1 and enc.billable_ind = 'N' and a.enc_id IS NOT NULL 
      THEN a.duration ELSE 0 END ) as enc_non_billable_linked_appt_dur_mins
	
   ,st1.created_by as User_Checkout_MA
   ,st1.Min_Kept_to_StatusUpdate as Cycle_Min_Kept_CheckedOut
   ,st2.created_by as User_ReadyforProvider_MA
   ,st2.Min_Kept_to_StatusUpdate as Cycle_Min_Kept_ReadyForProvider
   ,st3.Min_Kept_to_StatusUpdate  as Cycle_Min_Kept_Charted
   ,st4.Min_Since_last_StatusUpdate Cycle_Min_ReadyforProvider_Checkout
   ,enc.created_by as user_created_Encounter
	 
into staging_ng_appointment_data_
from #d d
  LEFT join [10.183.0.94].NGPROD.dbo.resources r
    on d.res_id = CAST(r.resource_id as varchar(36))
  left join [10.183.0.94].NGPROD.dbo.patient_encounter enc
    on d.enc_uid = cast(enc.enc_id as varchar(36)) 
  
  
   left join (
   SELECT 

      [enc_id]
      ,[created_by]
       ,[Min_Since_last_StatusUpdate]
     ,[Min_Kept_to_StatusUpdate]
  FROM [Staging_Ghost].[dbo].[staging_ng_status_data_] where txt_status like '%Checked-Out%'
        
   ) st1
    on d.enc_uid = cast(st1.enc_id as varchar(36)) 
 
  left join (
   SELECT 

      [enc_id]
      ,[created_by]
       ,[Min_Since_last_StatusUpdate]
     ,[Min_Kept_to_StatusUpdate]
  FROM [Staging_Ghost].[dbo].[staging_ng_status_data_] where txt_status like '%Ready for Provider%'
        
   ) st2
    on d.enc_uid = cast(st2.enc_id as varchar(36)) 
  
    
	 left join (
   SELECT 

      [enc_id]
      ,[created_by]
       ,[Min_Since_last_StatusUpdate]
     ,[Min_Kept_to_StatusUpdate]
  FROM [Staging_Ghost].[dbo].[staging_ng_status_data_] where txt_status like '%CHARTED%'
        
   ) st3
    on d.enc_uid = cast(st3.enc_id as varchar(36)) 
  
 
 	 left join (
   SELECT 

      [enc_id]
      ,[created_by]
       ,[Min_Since_last_StatusUpdate]
     ,[Min_Kept_to_StatusUpdate]
  FROM [Staging_Ghost].[dbo].[staging_ng_status_data_] where txt_status like '%Check-Out%'
        
   ) st4
    on d.enc_uid = cast(st4.enc_id as varchar(36)) 


    
  
  left join [10.183.0.94].NGPROD.dbo.location_mstr loc
    on enc.location_id = loc.location_id 
  left join [10.183.0.94].NGPROD.dbo.provider_mstr prov
    on enc.rendering_provider_id = prov.provider_id
  left join [10.183.0.94].NGPROD.dbo.appointments a
    on d.appt_nbr = a.appt_nbr
  left join [10.183.0.94].NGPROD.dbo.person per on per.person_id = enc.person_id




drop table #x
drop table #ar
drop table #d
 

 

END
GO
