SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <Create Date,,>
-- Description:	ETL data from ECW MySQL db
-- =============================================
CREATE PROCEDURE [dbo].[update_data_appointment_ecw]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('dbo.data_appointment_ecw_etl') IS NOT NULL
		DROP TABLE dbo.data_appointment_ecw_etl

	IF OBJECT_ID('tempdb..#appt_temp') IS NOT NULL
		DROP TABLE #appt_temp

/*
To mimic visit reporting finance receives for eCW sites
encounters for the following resource providers are never 
listed as billable -
Delia Delgado 38905
Gladys Garza 9152
Triage Nurse 65436

*/

    SELECT * INTO #appt_temp
	FROM OPENQUERY(ECWDB, 
'SELECT  DISTINCT   
	enc.encounterID AS enc_nbr,
	enc.patientID AS person_id,
	CASE
		WHEN enc.facilityId = 7
			or enc.facilityId = 8
			or enc.facilityId = 9
			or enc.facilityId = 10
			or enc.facilityId = 14 THEN 19
		WHEN enc.facilityId = 15
			or enc.facilityId = 17 THEN 4
		ELSE enc.facilityId 
	END
		AS location_id,
	users.uid AS provider_rendering_id,
	pat.rendPrId,
	pcp_prov.uid AS pcp_id,
	log.userId AS user_appt_created,
	date_format(log.date, ''%Y-%m-%d %T'') as appt_create_date,
	log.time as appt_create_time,
	date_format(enc.date,''%Y-%m-%d %T'') as enc_date,
	date_format(enc.startTime,''%Y-%m-%d %T'') as appt_start_time,
	date_format(enc.endTime,''%Y-%m-%d %T'') as appt_end_time,
	enc.STATUS AS status_long,
	v.status AS visit_status,
	enc.VisitType,
	CASE
		WHEN users.uid = 38905
			or users.uid = 9152
			or users.uid = 65436 Then 0
		WHEN enc.ClaimReq = 0 
			AND enc.date <= NOW() 
			AND (v.status = ''Check Out'' or v.status IS NULL) THEN 1
		WHEN v.NonBillable = 0 
			AND enc.date <= NOW() 
			AND (v.status = ''Check Out'' or v.status IS NULL)THEN 1
		ELSE 0
	END 
		AS nbr_bill_enc,
	
	CASE
		WHEN enc.date <= NOW() THEN 1
		ELSE 0
	END
		 AS all_enc_count,
		1 AS all_appt_count, 
	CASE
		WHEN v.status = ''No-Show''THEN ''Y'' ELSE ''N''
	END
		AS appt_noshow_ind,
	CASE 
		WHEN v.status = ''Cancelled'' THEN ''Y'' ELSE ''N''
	END
		AS appt_cancel_ind,
	CASE 
		WHEN v.status = ''Rescheduled'' THEN ''Y'' ELSE ''N''
	END
		AS appt_reschedule_ind,
	CASE
		WHEN v.status = ''No-Show'' THEN 1 ELSE 0
	END
		AS nbr_appt_no_show,
	CASE 
		WHEN v.status = ''Cancelled'' THEN 1 ELSE 0
	END
		AS nbr_appt_cancel,
	CASE 
		WHEN v.status = ''Rescheduled'' THEN 1 ELSE 0
	END
		AS nbr_appt_rescheduled,
	CASE 
		WHEN users.uid = pcp_prov.uid THEN 1
		ELSE 0
	END
		AS nbr_pcp_appts,
	CASE 
		WHEN users.uid = pcp_prov.uid THEN 0
		ELSE 1
	END
		AS nbr_nonpcp_appts,
	TIMESTAMPDIFF(DAY,log.date,enc.date) as days_to_appt,
	TIMESTAMPDIFF(MINUTE,enc.startTime,enc.endTime) as appt_duration,
	date_format(log.date,''%Y-%m-%d %T'') as appt_book_date,
	CASE
		WHEN enc.date > NOW() THEN 1
		ELSE 0
	END
		AS nbr_appt_future,
	ins1.insuranceName as pay1_name ,
    ins2.insuranceName as pay2_name ,
	 ins3.insuranceName as pay3_name

 FROM (mobiledoc.enc enc  
 LEFT  JOIN mobiledoc.patients pat on pat.pid = enc.patientID  
 LEFT  JOIN mobiledoc.users users  on enc.ResourceId = users.uid and (1 = users.UserType or 9 = users.UserType) and 0 = users.delFlag
 LEFT  JOIN mobiledoc.doctors pcp  ON pat.doctorId = pcp.doctorID 
 LEFT  JOIN mobiledoc.users pcp_prov  ON pcp.doctorID = pcp_prov.uid AND pcp_prov.UserType = 1 
 LEFT  JOIN mobiledoc.visitstscodes v  ON enc.STATUS = v.code)
 LEFT  JOIN mobiledoc.log log  ON log.encounterId = enc.encounterID AND log.actionFlag = 0
 LEFT OUTER JOIN mobiledoc.insurancedetail ins1_det on (pat.pid = ins1_det.pid and 1 = ins1_det.SeqNo and 0 = ins1_det.DeleteFlag )
 LEFT OUTER JOIN mobiledoc.insurance ins1 on (ins1_det.insid = ins1.insId and ins1_det.SeqNo = 1 and 0 = ins1.deleteFlag and ins1_det.DeleteFlag = 0)
 LEFT OUTER JOIN mobiledoc.insurancedetail ins2_det on (pat.pid = ins2_det.pid and 2 = ins2_det.SeqNo and 0 = ins2_det.DeleteFlag)
 LEFT OUTER JOIN mobiledoc.insurance ins2 on (ins2_det.insid = ins2.insId and ins2_det.SeqNo = 2 and 0 = ins2.deleteFlag and ins2_det.DeleteFlag = 0) 
 LEFT OUTER JOIN mobiledoc.insurancedetail ins3_det on (pat.pid = ins3_det.pid and 3 = ins3_det.SeqNo and 0 = ins3_det.DeleteFlag)
 LEFT OUTER JOIN mobiledoc.insurance ins3 on (ins3_det.insid = ins3.insId and ins3_det.SeqNo = 3 and 0 = ins3.deleteFlag)
 
 WHERE (enc.VisitType is null or enc.VisitType <> ''PTDASH'')
 AND enc.patientID <> 8663 
 AND enc.deleteFlag = 0 
 AND enc.deleteFlag = 0
 AND enc.date >= ''2010-01-01''  ')


 SELECT 
	IDENTITY(INT,1,1) AS ecw_enc_key,
	t.*,
	CASE
		WHEN t.nbr_pcp_appts=1 THEN 'Appointment With PCP'
		ELSE 'Appointment Without PCP'
	END
		AS pcp_appointment
INTO dbo.data_appointment_ecw_etl
FROM #appt_temp t



END
GO
