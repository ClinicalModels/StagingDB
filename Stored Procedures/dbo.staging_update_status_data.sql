SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_status_data]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/****** Script for SelectTopNRows command from SSMS  ******/

/****** Script for SelectTopNRows command from SSMS  ******/


IF OBJECT_ID('staging_ng_status_data_') IS NOT NULL DROP TABLE staging_ng_status_data_ 


declare @build_dt_start varchar(8), @build_dt_end varchar(8)
--set @build_dt_start = CONVERT(varchar(8), DATEADD(DAY,-1,cast(GETDATE() as date)),112) --This routine will build current and hx data from begin to end date 
set @build_dt_end =CONVERT(varchar(8), DATEADD(DAY,-1,cast(GETDATE() as date)),112)


set @build_dt_start = '20100301'

SELECT 
	  enc.rendering_provider_id
	  ,cast (enc.checkin_datetime as date) as CheckinDate
	  ,enc.location_id
	  ,enc.[billable_ind]
	  ,pah.[enterprise_id]
      ,pah.[practice_id]
      ,pah.[person_id]
      ,pah.[enc_id]
      ,pah.[seq_no]
      ,pah.[created_by]
      ,pah.[create_timestamp]
      ,pah.[modified_by]
      ,pah.[modify_timestamp]
      ,pah.[create_timestamp_tz]
      ,pah.[modify_timestamp_tz]

      ,pah.[txt_documented_by]
      ,pah.[txt_room]
      ,pah.[txt_status]
      ,pah.[txt_time]
      ,pah.[txt_appt_time]
	  ,enc.checkin_datetime
	  ,datediff(mi,enc.checkin_datetime,pah.create_timestamp) as Min_Kept_to_StatusUpdate
	  ,(datediff(mi,enc.checkin_datetime,pah.create_timestamp)-LAG(datediff(mi,enc.checkin_datetime,pah.create_timestamp), 1,0) OVER (partition by enc.enc_id ORDER BY pah.create_timestamp ) ) as Min_Since_Last_StatusUpdate

 into #temp1

  FROM  [10.183.0.94].NGPROD.dbo.[pat_apt_status_hx_] pah 
  inner join  [10.183.0.94].NGPROD.dbo.patient_encounter enc on pah.enc_id = enc.enc_id 
  where (cast (enc.checkin_datetime as date) >= (cast(@build_dt_start as date)) ) and  (cast (enc.checkin_datetime as date) <= cast(@build_dt_end as date)  )

  
SELECT 
 	  [enc_id]
      ,[person_id]
      ,rendering_provider_id
	  ,location_id
      ,[created_by]
      ,[modified_by]
      ,CheckinDate
	  ,[modify_timestamp]
      ,checkin_datetime
	  ,[txt_room]
      ,[txt_status]
	  --,rank_order
	  ,Merged_Min_Since_last_StatusUpdate as Min_Since_last_StatusUpdate 
	  ,Merged_Min_Kept_to_StatusUpdate as Min_Kept_to_StatusUpdate 
	  --,Min_Since_last_StatusUpdate
	  --,Min_Kept_to_StatusUpdate

into [dbo].[staging_ng_status_data_]

from (SELECT 
 	  [enc_id]
      ,[person_id]
      ,rendering_provider_id
	  ,location_id
      ,[created_by]
      ,[modified_by]
      ,CheckinDate
	  ,[modify_timestamp]
      ,checkin_datetime
	  ,[txt_room]
      ,[txt_status]
	  ,Min_Kept_to_StatusUpdate
	  ,Min_Since_Last_StatusUpdate
	  ,rank_order = ROW_NUMBER() over (
			partition by enc_id,txt_status
			order by modify_timestamp asc
			)
	  , (isnull(lead(Min_Since_Last_StatusUpdate,1) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		
		isnull(lead(Min_Since_Last_StatusUpdate,2) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		isnull(lead(Min_Since_Last_StatusUpdate,3) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		isnull(lead(Min_Since_Last_StatusUpdate,4) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		isnull(lead(Min_Since_Last_StatusUpdate,5) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+  Min_Since_Last_StatusUpdate)
				 
		  as Merged_Min_Since_last_StatusUpdate,



		  (isnull(lead(Min_Since_Last_StatusUpdate,1) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		
		isnull(lead(Min_Since_Last_StatusUpdate,2) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		isnull(lead(Min_Since_Last_StatusUpdate,3) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		isnull(lead(Min_Since_Last_StatusUpdate,4) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)+
		isnull(lead(Min_Since_Last_StatusUpdate,5) over (
			partition by enc_id,txt_status
			order by modify_timestamp asc),0)
		) +min_Kept_to_StatusUpdate as Merged_Min_Kept_to_StatusUpdate
      



from #temp1 ) x where  rank_order =1






  END






  --  Minutes from KEPT to ready for provider with Ready Provider user_id
  -- Minutes from Minutes from Ready from Provider to Charted by user_id
  -- Minutes from Ready for Provider to Checked-Out and User_id
 
GO
