SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_next_available_data_hx]
AS
BEGIN

/*FIRST AND THIRD AVAILABLE APPT REPORT
Modified to be generalizable and include historical data

CREATED BY MICO REYES

UPDATED 07/12/2012
-dynamic start time
-fix bug with complex choosing a different category for second slot (in progress)

UPDATED 07/10/2012
-changed ranking from int to varchar
-added ordinal ranking using MOD

UPDATED 07/09/2012

-added location
-changed all datetime to varchar(8) for appt_date


*/
declare @build_dt_start varchar(8), @build_dt_end varchar(8), @Build_counter varchar(8)


set @build_dt_start = CONVERT(varchar(8),GETDATE(),112) --This routine will build current and hx data from begin to end date 
set @build_dt_end =CONVERT(varchar(8),GETDATE(),112)

set @build_dt_start = '20150621'

set @build_dt_end ='20150622'


set @build_counter = @build_dt_start


WHILE (@build_counter <= @build_dt_end)  -- LOOP UNTIL END DATE


BEGIN 

PRINT 'WORKING ON DATE:' + @Build_counter

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
IF OBJECT_ID('tempdb..#category') IS NOT NULL DROP TABLE #category
IF OBJECT_ID('tempdb..#event_filter') IS NOT NULL DROP TABLE #event_filter
IF OBJECT_ID('tempdb..#final_table') IS NOT NULL DROP TABLE #final_table
IF OBJECT_ID('tempdb..#open_appt_slots') IS NOT NULL DROP TABLE #open_appt_slots
IF OBJECT_ID('tempdb..#temp_timeslots') IS NOT NULL DROP TABLE #temp_timeslots

-- INITIALIZE VARIABLES

DECLARE @dt_start varchar(8),
  @dt_end varchar(8),
  @dt varchar(8),
  
  @event varchar(200),
  @event_id uniqueidentifier,
  @ev_dur int,
  
  @category_id varchar(200),
  
  @resources varchar(200),
  @res_id uniqueidentifier,
  
  @apptdate varchar(8),
  @resource_id  uniqueidentifier,
  
  @slot char(4),
  @ranking int,
  @slot_count int,
  @slot_time datetime,
  @next_slot_time varchar(8),
  
  @rtn_value int,
  
  @event_name varchar(100),
  @resource_name varchar(100),
  @loc uniqueidentifier
  
-- GET END DATE FROM RESOURCE TEMPLATES

PRINT CAST(getdate() as varchar(20))+ ': GENERATING END DATE FROM RESOURCE TEMPLATES'
  
SET  @dt_start = @Build_counter
set  @dt_end =convert(varchar(8), DATEADD(d,180,cast(@Build_counter as datetime)), 112)

/*
SET  @dt_end = (SELECT
  MAX(rt.week_end_date)
  FROM [10.183.0.94].[NGProd].[dbo].resource_templates rt)
 
 */
 
 
 
 SET  @dt = @dt_start  


--GRAB TABLES INTO TEMP TABLES
-- dbo.appointments to appointments
-- dbo.appt_slot_templates to #apt_slot_temp
-- dbo.appointment_members to #appt_members

--INITIALIZE TABLES
/*
CREATE TABLE #open_appt_slots (resource_id varchar(200), begintime varchar(4), duration int, 
  category_id varchar(200), location_id varchar(200), appt_date varchar(8))
*/

CREATE TABLE #open_appt_slots (resource_id [uniqueidentifier] NULL, begintime varchar(4), duration int, 
  category_id [uniqueidentifier] NULL, location_id [uniqueidentifier] NULL, appt_date varchar(8))

  CREATE INDEX PIndex
ON #open_appt_slots (resource_id, location_id, category_id)
  CREATE INDEX XIndex
ON #open_appt_slots (resource_id)

  CREATE INDEX YIndex
ON #open_appt_slots (appt_date,begintime)


  CREATE INDEX ZIndex
ON #open_appt_slots (begintime)


CREATE TABLE #event_filter (event_name varchar(200), event_id uniqueidentifier, ev_duration int)

--FILTER BY EVENTS, FOLLOWUP, COMPLEX, URGENT

PRINT CAST(getdate() as varchar(20))+ ': GENERATING EVENT FILTERS'


INSERT INTO #event_filter (event_name,event_id,ev_duration)
SELECT distinct ev.event, ev.event_id, ev.duration
FROM [10.183.0.94].[NGProd].[dbo].appointments a
INNER JOIN [10.183.0.94].[NGProd].[dbo].appointment_members am
  ON a.appt_id = am.appt_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].events ev
  ON a.event_id = ev.event_id
--INNER JOIN [10.183.0.94].[NGProd].[dbo].resources r
--  ON am.resource_id = r.resource_id
--LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_slot_templates ast
--  ON a.begintime <= ast.begintime
--  AND a.endtime > ast.begintime
--  AND  (ast.day = 0  or ast.day = DATEPART(dw,@dt)) 
     WHERE ((a.appt_date >= @dt_start or  a.appt_date <= @dt_end ) 
  and a.create_timestamp <= convert(datetime, @dt_start+' 06:59:59.99')
  and (a.cancel_ind = 'N'and a.resched_ind = 'N' and a.delete_ind = 'N')) 
    or 
		
	((a.appt_date >= @dt_start or  a.appt_date <= @dt_end )
  and a.modify_timestamp >=  convert(datetime, @dt_start+' 06:59:59.99')
  and a.create_timestamp <= convert(datetime, @dt_start+' 06:59:59.99')
  and (a.cancel_ind = 'Y'or a.resched_ind = 'Y' or a.delete_ind = 'Y')) 












/*
WHERE ev.event_id in (
          '67A75671-44E6-4EDC-B6B3-0809D1822DA0'
        , '27FB7AC1-F5DE-4D53-9F8C-2F7118DC64D7'
        , 'B9152800-9C0B-4928-85AE-3251896FA613'
        , '7D3BEE2A-2035-4DD4-AABC-15F86EC3AF64'
        , '530697A8-D177-4859-931E-E700872B273E'
        , 'EE4B0D26-8AC7-4F7E-9EE0-FC164235F6F0'
        , 'DC05A4E3-8D3F-4854-874E-E923D6B69392'
        , '11FF11A7-2FAE-4471-977A-D1AC573CD97D'
        , 'F822F738-7138-484E-8BE6-7BB07E14781A'
		, '3E51BA03-BB36-4A55-9748-86721CA371A1'
		, 'ED9D37C6-FC07-410C-9871-014203A345EC'
		, 'B1310A66-D812-45DF-A08E-48A40747778A' 
		, '56DDC0DF-C5F7-4956-95F4-4294DE957E23'
		, '6E4BEB4D-A1D6-424E-B7C2-6BF5195261FB'
		, 'E23C6000-AB60-4856-ABAD-F091D02DE930'
       
        ) 
		
*/	
--Commenting out a selected group of events to search for		
-- drop samedays, really should eliminate this event from the category type
        


-- Standard Visit -- 67A75671-44E6-4EDC-B6B3-0809D1822DA0  
-- Standard Visit Long -- 27FB7AC1-F5DE-4D53-9F8C-2F7118DC64D7

-- Podiatry Short -- B9152800-9C0B-4928-85AE-3251896FA613
-- Podiatry Long -- 7D3BEE2A-2035-4DD4-AABC-15F86EC3AF64  Podiatry Long

--530697A8-D177-4859-931E-E700872B273E  Behavioral Short
--EE4B0D26-8AC7-4F7E-9EE0-FC164235F6F0  Behavioral Long
--DC05A4E3-8D3F-4854-874E-E923D6B69392  Behavioral Extra Long

-- 11FF11A7-2FAE-4471-977A-D1AC573CD97D Pediatric Short PED
-- F822F738-7138-484E-8BE6-7BB07E14781A Pediatric Long  PLG

-- Same Day -- 3E51BA03-BB36-4A55-9748-86721CA371A1
-- ED9D37C6-FC07-410C-9871-014203A345EC Walk-In

-- B1310A66-D812-45DF-A08E-48A40747778A New Patient Same Day
-- 56DDC0DF-C5F7-4956-95F4-4294DE957E23 New Patient (Un)
-- 6E4BEB4D-A1D6-424E-B7C2-6BF5195261FB New Patient (I)






--START LOOKING FOR OPEN APPOINTMENT SLOTS
--1) APPT WITH BOOKED < LIMIT
--2) OPEN SLOTS


--LOOP UNTIL END DATE

PRINT CAST(getdate() as varchar(20))+ ': GENERATING OPEN SLOTS'
WHILE (@dt <= @dt_end)  -- LOOP UNTIL END DATE
BEGIN 

-- 1) APPT WITH BOOKED < LIMIT
-- TEMPLATE SLOTS WITH AVAILABLE APPOINTMENTS BASED ON APPT BOOKED < APPT LIMIT
INSERT INTO #open_appt_slots
SELECT 
  rt.resource_id
  ,temp_begintime = ast.begintime
  ,ast.duration
  ,ast.category_id
  ,ast.location_id
  ,apptdate = @dt

FROM [10.183.0.94].[NGProd].[dbo].appointments a
INNER JOIN [10.183.0.94].[NGProd].[dbo].appointment_members am
  ON a.appt_id = am.appt_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].events ev
  ON a.event_id = ev.event_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].resources r
  ON am.resource_id = r.resource_id
LEFT JOIN [10.183.0.94].[NGProd].[dbo].appt_slot_templates ast
  ON a.begintime <= ast.begintime
  AND a.endtime > ast.begintime
  AND  (ast.day = 0  or ast.day = DATEPART(dw,@dt)) 


INNER JOIN [10.183.0.94].[NGProd].[dbo].resource_templates rt 
  ON ast.appt_template_id = rt.appt_template_id

  AND rt.week_start_date <= @dt
  AND rt.week_end_date >= @dt  





   WHERE (a.appt_date = @dt  
  and a.create_timestamp <= convert(datetime, @dt_start+' 06:59:59.99')
  and (a.cancel_ind = 'N'and a.resched_ind = 'N' and a.delete_ind = 'N')) 
    or 
	
	
	(a.appt_date = @dt
  and a.modify_timestamp >=  convert(datetime, @dt_start+' 06:59:59.99')
  and a.create_timestamp <= convert(datetime, @dt_start+' 06:59:59.99')
  and (a.cancel_ind = 'Y'or a.resched_ind = 'Y' or a.delete_ind = 'Y')) 
/*

WHERE a.appt_date = @dt
  AND am.resource_id = rt.resource_id
  AND a.cancel_ind = 'N'
  AND a.resched_ind = 'N'
  AND a.delete_ind = 'N'
  and a.create_timestamp <= cast(@dt_start  as datetime)
--  and   r.resource_id = 'BCA75B67-1485-4AE4-9AD8-12DD36288DE5'
*/

GROUP BY rt.resource_id, ast.begintime, ast.duration, ast.category_id, ast.location_id
HAVING COUNT(ast.begintime) < max(ast.overbook_limit)



--PRINT CAST(getdate() as varchar(20)) + ':GRAB OPEN SLOTS FROM TEMPLATES'
-- 2) OPEN SLOTS
-- GRAB ALL OPEN SLOTS AND ADD TO OPEN APPT SLOT TABLE

INSERT INTO #open_appt_slots
SELECT 
  rt.resource_id,
  ast.begintime,
  ast.duration,
  ast.category_id,
  ast.location_id,
  apptdate=@dt

FROM [10.183.0.94].[NGProd].[dbo].appt_slot_templates ast
INNER JOIN [10.183.0.94].[NGProd].[dbo].resource_templates rt
  ON ast.appt_template_id = rt.appt_template_id
  AND rt.week_start_date <= @dt
  AND rt.week_end_date >= @dt
  AND  (ast.day = 0  or ast.day = DATEPART(dw,@dt)) 
  
LEFT JOIN (
  SELECT a.appt_date,
  a.appt_id,
  a.begintime,
  a.endtime,
  a.event_id,
  am.resource_id
  
  FROM [10.183.0.94].[NGProd].[dbo].appointments a
  INNER JOIN [10.183.0.94].[NGProd].[dbo].appointment_members am
  ON a.appt_id = am.appt_id
  
  /*
  WHERE a.appt_date = @dt
  AND a.cancel_ind = 'N'
  AND a.resched_ind = 'N'
  AND a.delete_ind = 'N'
  and a.create_timestamp <= cast(@dt_start  as datetime)
  */

  --Appointments availabity on dat @dt as seen from  perspective of @dt_start  at 7AM 
  --First is all appointments never changed and then add back appointment that were later changed.
  --Problem here is if there are multiple appointments per slots

   WHERE (a.appt_date = @dt  
  and a.create_timestamp <= convert(datetime, @dt_start+' 06:59:59.99')
  and (a.cancel_ind = 'N'and a.resched_ind = 'N' and a.delete_ind = 'N')) 
    or 
	
	
	(a.appt_date = @dt
  and a.modify_timestamp >=  convert(datetime, @dt_start+' 06:59:59.99')
  and a.create_timestamp <= convert(datetime, @dt_start+' 06:59:59.99')
  and (a.cancel_ind = 'Y'or a.resched_ind = 'Y' or a.delete_ind = 'Y')) 
	
	  
  
  
  ) a
  ON ast.begintime >= a.begintime
  AND ast.begintime < a.endtime
    AND  (ast.day = 0  or ast.day = DATEPART(dw,@dt)) 
  AND rt.resource_id = a.resource_id

WHERE a.appt_id IS NULL 
--and       rt.resource_id = 'BCA75B67-1485-4AE4-9AD8-12DD36288DE5'

-- CHECK NEXT DAY AND LOOP FROM START
SET @dt = convert(varchar(8), DATEADD(d,1,cast(@dt as datetime)), 112)
END;


--PRINT CAST(getdate() as varchar(20)) + ': START LOOKING FOR 1st and 3rd APPTS'

-- create FINAL table to put all results in
CREATE TABLE #final_table (resource_id uniqueidentifier, days_away int, appt_date varchar(10),
  begintime varchar(4), ranking varchar(4), location_id uniqueidentifier, event_id uniqueidentifier
  ,rank_nbr int)



/*   USING CURSOR TO PARSE THROUGH RESOURCES(FILTERED BY MULTIVIEW GROUP = PROVIDERS)
  ANOTHER CURSOR TO RUN THROUGH EACH EVENT
  ANOTHER CURSOR TO RUN THROUGH EACH APPOINTMENT DATE
  LASTLY A LOOP TO RUN THROUGH EACH OPEN SLOT TIME ON THE SPECIFIC DAY
  INSERT TOP 3 OPEN SLOTS INTO FINAL TABLE
  IF MULTIPLE 15 MIN SLOTS PER TABLE, SKIP THE NEXT FEW SLOTS BY USING A FETCH NEXT

  RESOURCE > EVENT > APPT_DATE > APPT SLOT TIME
*/
DECLARE cur_location CURSOR FAST_FORWARD
  FOR SELECT DISTINCT  oasloc.location_id
  FROM #open_appt_slots oasloc
  
  /*WHERE oasloc.resource_id IN 
  (SELECT sur.resource_id
  FROM [10.183.0.94].[NGProd].[dbo].sched_user_resources sur
  INNER JOIN [10.183.0.94].[NGProd].[dbo].resources r
  ON sur.resource_id = r.resource_id
  WHERE sur.multiview_id like 'providers' and sur.user_id = -97
  )
  */

  OPEN cur_location
  FETCH NEXT FROM cur_location
  INTO @loc
  
  WHILE @@FETCH_STATUS=0 
  BEGIN
  -- RESOURCES
  DECLARE cur_resource CURSOR FAST_FORWARD
  FOR 
  -- CUE UP Resources
  
  SELECT DISTINCT r.resource_id
  FROM  [10.183.0.94].[NGProd].[dbo].resources r
 INNER JOIN #open_appt_slots oas
  ON r.resource_id = oas.resource_id
  where  oas.location_id = @loc  
 
  /*
  --WHERE sur.multiview_id like 'providers' and sur.user_id = -97
  AND oas.location_id = @loc
  */
 
  OPEN cur_resource
  FETCH NEXT FROM cur_resource
  INTO @res_id

  WHILE @@FETCH_STATUS=0
  BEGIN
  SET @resource_name = (SELECT description FROM [10.183.0.94].[NGProd].[dbo].resources r WHERE r.resource_id = @res_id)
  --PRINT 'CHECKING RESOURCE: ' + @resource_name
   --LOOP THROUGH EVENTS follow up, urgent, duration
  
  DECLARE cur_event CURSOR FAST_FORWARD
  FOR SELECT ef.event_id, ef.event_name, ef.ev_duration 
  FROM #event_filter ef
  OPEN cur_event
  FETCH NEXT FROM cur_event
  INTO @event_id, @event, @ev_dur
  
  -- Generate Category_id that links to event_id



  WHILE @@FETCH_STATUS = 0 
  BEGIN -- FIND EVENT
  
  CREATE TABLE #category (category_id uniqueidentifier)
  INSERT INTO #category ( category_id )
  SELECT cm.category_id
  FROM [10.183.0.94].[NGProd].[dbo].category_members cm
  WHERE cm.event_id = @event_id
  
  SET @event_name = (SELECT event FROM [10.183.0.94].[NGProd].[dbo].events e WHERE e.event_id = @event_id)
  --PRINT 'CHECKING EVENT: ' + @event_name
  
  
  /* Check all open slots one by one, and look if there are additional 15 min slots 
   to meet the desired duration, if there is, insert slot into final table and then 
   skip the next few entries in cursor depending on how many more 15 min slots the appt will take */
  SET @ranking = 1
  DECLARE cur_apptdate CURSOR FAST_FORWARD
  FOR SELECT distinct oas.appt_date
  FROM #open_appt_slots oas
  WHERE oas.resource_id = @res_id
  AND oas.location_id = @loc
  ORDER BY oas.appt_date
  
  OPEN cur_apptdate
  
  FETCH NEXT FROM cur_apptdate
  INTO @apptdate
  
  WHILE @@FETCH_STATUS = 0 AND @ranking <= 5
  BEGIN -- FIND DATE
  
  --PRINT 'CHECKING DATE: ' + @apptdate
  -- Filter by resource and category
  
  SELECT oas3.begintime
  INTO #temp_timeslots
  FROM #open_appt_slots oas3
  INNER JOIN #category cur_cat
  ON cur_cat.category_id = oas3.category_id
  WHERE  oas3.resource_id = @res_id 
  AND oas3.appt_date = @apptdate
  AND oas3.location_id = @loc
  AND ((@apptdate=@dt_start 
  -- if apptdate is today, only get slots greater than the current time + 1 min
  AND oas3.begintime > (left(convert(varchar(8),@dt_start,108),2) + SUBSTRING(convert(varchar(8),dateadd(mi,1,getdate()),108),4,2)))
  OR @apptdate > @dt_start)
  ORDER BY oas3.appt_date, oas3.begintime
  
   DECLARE timeslot CURSOR FAST_FORWARD
  FOR SELECT begintime
  FROM #temp_timeslots
  
  --testing
  
  
  
   OPEN timeslot
   FETCH NEXT FROM timeslot
   INTO @slot
   
   
   -- use for ranking 1st, 2nd, 3rd etc available appt
  
   
   WHILE @@FETCH_STATUS = 0 AND @ranking <= 5
   BEGIN -- FIND TIME
  
  -- How many extra slots needed to fill duration
  SET @slot_count = (@ev_dur/15) - 1
  
  -- @slot_time = next slot
  -- @next_slot_time = next slot converted to HHMM
  SET @slot_time = dateadd(mi, @ev_dur - 15, SUBSTRING(@slot, 1,2) + ':' + SUBSTRING(@slot,3,2))
  SET @next_slot_time = RIGHT('0' + datename(HH,@slot_time),2) + RIGHT('0' + datename(mi,@slot_time),2)
  
  --PRINT 'CHECKING TIME SLOT: ' + @slot
  
  -- find the next slots
  SELECT @rtn_value = COUNT(begintime)
  FROM #temp_timeslots os
  WHERE @next_slot_time = begintime
  
  -- if there are slots found, insert to final table
 -- IF @rtn_value >= @slot_count PRINT 'FOUND SLOT ' + cast(@ranking as varchar(3)) + ' ' + @slot
  
  IF @rtn_value >= @slot_count
  BEGIN -- SELECT FIRST OR THIRD
 -- IF @ranking = 1 OR @ranking = 3 -- SELECT ONLY 1st and 3rd available
  IF @ranking <= 5
  BEGIN -- INSERT TO FINAL
  INSERT INTO #final_table (resource_id, days_away, appt_date, begintime, ranking,
    location_id, event_id, rank_nbr)
  VALUES (@res_id, datediff(dd,@dt_start,@apptdate) ,@apptdate, @slot, @ranking, @loc, @event_id, @ranking)
  END -- INSERT TO FINAL
  -- skip the next few(@slot_count) appt slots from search
  WHILE @slot_count > 0
  BEGIN -- SKIP NEXT SLOTS
  FETCH NEXT FROM timeslot INTO @slot
  SET @slot_count = @slot_count - 1
  END  -- SKIP NEXT SLOTS
  SET @ranking = @ranking + 1
  
  END -- SELECT FIRST OR THIRD
  FETCH NEXT FROM timeslot INTO @slot
  END -- FIND TIME
  
  
  CLOSE timeslot
  DEALLOCATE timeslot
  DROP TABLE #temp_timeslots
  FETCH NEXT FROM cur_apptdate INTO @apptdate
  END -- FIND DATE
  
  CLOSE cur_apptdate
  DEALLOCATE cur_apptdate
  
  
  FETCH NEXT FROM cur_event INTO  @event_id, @event, @ev_dur
  DROP TABLE #category
  END -- FIND EVENT
  
  CLOSE cur_event
  DEALLOCATE  cur_event
   
  
  
  
  FETCH NEXT FROM cur_resource INTO @res_id
  END  
  
  
  CLOSE cur_resource
  DEALLOCATE cur_resource
  
  FETCH NEXT FROM cur_location INTO @loc
  END
  
CLOSE cur_location
DEALLOCATE cur_location
-- SHOW ALL APPTS IN FINAL TABLE
/*
SELECT  r.description,
  ev.event, 
  loc.location_name,
  ft.*

FROM #final_table ft
INNER JOIN resources r
  ON ft.resource_id = r.resource_id
INNER JOIN events ev
  ON ft.event_id = ev.event_id
INNER JOIN location_mstr loc
  ON ft.location_id = loc.location_id
  */

UPDATE ft
SET ft.ranking = CAST(ft.ranking as varchar(5)) + (SELECT suffix = 
  CASE WHEN (ft.ranking % 100) = 11
  THEN 'th'
  
  WHEN (ft.ranking % 100) = 12
  THEN 'th'
  
  WHEN (ft.ranking % 100) = 13
  THEN 'th'
  
  WHEN (ft.ranking % 10) = 1
  THEN 'st'
  
  WHEN (ft.ranking % 10) = 2
  THEN 'nd'
  
  WHEN (ft.ranking % 10) = 3
  THEN 'rd'
  
  ELSE 'th'
  END)
  
FROM #final_table ft


delete 
from dbo.staging_ng_next_available_data_
where run_date = @dt_start



/*

SELECT  
  newid() as seq_no
  ,r.description as resource_desc,
  r.resource_id as resource_id ,
  prov.description as provider_desc
  ,prov.provider_id as provider_id
  ,ev.event as event, 
  loc.location_name as location_name, 
  ft.days_away as  days_away,
   SUBSTRING(ft.appt_date,5,2) +'/'+ RIGHT(ft.appt_date,2) +'/'+ LEFT(ft.appt_date,4) as appt_date ,
   convert(varchar,cast((ft.begintime/100+11)%12+1 as varchar(2))
    + ':' + SUBSTRING(cast((ft.begintime%100+100) as char(3)),2,2)
    + ' ' + SUBSTRING('ap',ft.begintime/1200%2+1,1)+'m',108) as begintime
  ,ft.rank_nbr as ranking
  ,ft.ranking as rank_txt
  ,cast(ft.appt_date + ' ' + convert(varchar,cast((ft.begintime/100+11)%12+1 as varchar(2))
    + ':' + SUBSTRING(cast((ft.begintime%100+100) as char(3)),2,2)
    + ' ' + SUBSTRING('ap',ft.begintime/1200%2+1,1)+'m',108) as datetime) as appt_datetime,
  convert(char(8), getdate(), 112) as run_date

into dbo.ftnaa_data

*/

insert into dbo.staging_ng_next_available_data_ (


    [seq_no] ,
  [resource_id] ,
  [provider_id] ,
  [location_id] ,
    [event_id] ,

    
    [resource_desc] ,
  [provider_desc] ,
  [event],
  [location_name] ,
  [days_away],
  [appt_date],
  [begintime],
  [ranking] ,
  [rank_txt],
  [appt_datetime] ,
  [run_date] ,
  [run_date_dt] 

  )


SELECT  
  newid()
  ,r.resource_id
  ,prov.provider_id
  ,loc.location_id
  ,ev.event_id


  ,r.description,
  prov.description
  ,ev.event, 
  loc.location_name, 
  ft.days_away,
  appt_date = SUBSTRING(ft.appt_date,5,2) +'/'+ RIGHT(ft.appt_date,2) +'/'+ LEFT(ft.appt_date,4),
  begintime = convert(varchar,cast((ft.begintime/100+11)%12+1 as varchar(2))
    + ':' + SUBSTRING(cast((ft.begintime%100+100) as char(3)),2,2)
    + ' ' + SUBSTRING('ap',ft.begintime/1200%2+1,1)+'m',108)
  ,rank_nbr = ft.rank_nbr
  ,ft.ranking
  ,appt_dt = cast(ft.appt_date + ' ' + convert(varchar,cast((ft.begintime/100+11)%12+1 as varchar(2))
    + ':' + SUBSTRING(cast((ft.begintime%100+100) as char(3)),2,2)
    + ' ' + SUBSTRING('ap',ft.begintime/1200%2+1,1)+'m',108) as datetime)
  ,convert(char(8), @dt_start, 112)
  ,cast(@dt_start as date)


FROM #final_table ft
INNER JOIN [10.183.0.94].[NGProd].[dbo].resources r
  ON ft.resource_id = r.resource_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].events ev
  ON ft.event_id = ev.event_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].location_mstr loc
  ON ft.location_id = loc.location_id
left join [10.183.0.94].[NGProd].[dbo].provider_mstr prov
  on r.phys_id = prov.provider_id
ORDER BY r.description, loc.location_name, ev.event



--SELECT r.description,*
--FROM #open_appt_slots oas
--INNER JOIN resources r
--  ON oas.resource_id = r.resource_id
--ORDER BY r.description


-- DROP TEMPORARY TABLES
DROP TABLE #event_filter
DROP TABLE #final_table
DROP TABLE #open_appt_slots

PRINT 'COMPLETED WORK FOR ' + @Build_counter
SET @Build_counter = convert(varchar(8), DATEADD(D,1,cast(@Build_counter as datetime)), 112)
END;

--end

/*
update dbo.ftnaa_data
set most_recent_ind = case 
  when run_date = convert(char(8), getdate(), 112)
  then 'Y' else 'N' end

  

END
*/


END
GO
