SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <Create Date,,>
/* Description:	1.5 Minute run

*/
-- =============================================
CREATE PROCEDURE [dbo].[update_data_patient_ecw]
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --allow for dirty reads

	IF OBJECT_ID('dbo.data_patient_ecw') IS NOT NULL
		DROP TABLE dbo.data_patient_ecw

	IF OBJECT_ID('tempdb..#patient_temp') IS NOT NULL
		DROP TABLE #patient_temp

	IF OBJECT_ID('tempdb..#mh_cleanup') IS NOT NULL
		DROP TABLE #mh_cleanup
/*
date_format() is used due to the high number of garbage values in the datetime columns.
There were a number of errors coming up when attepting to read values out of the range 
of SQL Sever. 

Instead of using departments the clinics create separate locations for each department, the
CASE statement assesses which location each one corresponds to and assigns them a uniform ID

UID 50 is Fax Machine, UID 8663 is filtered by Cognos

*/
SELECT * INTO #patient_temp
FROM OPENQUERY(ECWDB,'

   SELECT DISTINCT
	users.uid AS patient_id , 
	pat.doctorId AS pcp_id,
	CASE
		WHEN fac.facilitynickname LIKE ''%San Pablo%'' THEN 19
		WHEN fac.facilitynickname LIKE ''%Richmond%'' THEN 4
		WHEN fac.portal_name LIKE  ''%San Pablo%'' THEN 19
		WHEN fac.portal_name LIKE ''%Richmond%'' THEN 4
		WHEN fac.portal_name LIKE ''%ECHS%'' THEN 5
		ELSE users.primaryservicelocation 
	END
		AS med_home_id_orig,
	pat.ControlNo as patient_account_number, 
	users.ulname as last_name , 
	users.ufname as first_name ,
	e.Name as ethnicity, 
	pat.hl7Id as med_rec_nbr,  
	users.ssn,
	users.upPhone AS home_phone,
	users.umobileno AS alt_phone,
	users.upaddress AS address_line_1,
	users.upaddress2 AS address_line_2,
	users.upcity AS city,
	users.upstate AS state,
	users.zipcode AS zip,
	date_format(users.ptDob, ''%Y-%m-%d'') AS date_of_birth,
	date_format(pin.deceaseddate, ''%Y-%m-%d'') AS expired_date,
	pat.race AS race,
	pat.deceased,
	pat.language,
	CASE
		WHEN users.sex LIKE ''female'' THEN ''F''
		WHEN users.sex LIKE ''male'' THEN ''M''
		ELSE ''U''
	END
		AS sex,
	CASE
		WHEN pat.maritalstatus LIKE ''Single'' THEN ''S''
		WHEN pat.maritalstatus LIKE ''Married'' THEN ''M''
		ELSE ''U''
	END
		AS marital_status
 FROM (mobiledoc.patients pat 
 INNER JOIN mobiledoc.users users on pat.pid = users.uid and 0 = users.delFlag)
 LEFT JOIN mobiledoc.edi_facilities fac on fac.Id = users.primaryservicelocation
 LEFT JOIN mobiledoc.ethnicity e on e.Code = pat.ethnicity
 LEFT JOIN mobiledoc.patientinfo pin on pin.pid = pat.pid
 where users.uid <> 8663
 AND users.uid <> 50 
 AND users.ulname NOT LIKE ''%test''
 AND users.ulname NOT LIKE ''zz%''
 AND users.ufname NOT LIKE ''%test%''
 ')


IF OBJECT_ID('tempdb..#first_date_clean') IS NOT NULL
	DROP TABLE #first_date_clean

/*
Pull all patient encounters, group by patient id and order by encounter date.
Patient's earliest encounter will be rowNum = 1
*/
SELECT 
ROW_NUMBER() OVER(PARTITION BY uid ORDER BY date ASC) AS rowNum ,
uid,
date
INTO #first_date_clean
FROM OPENQUERY(ECWDB,'
SELECT us.uid, enc.date
FROM ( mobiledoc.enc enc
INNER JOIN mobiledoc.patients pat ON enc.patientID=pat.pid)
LEFT JOIN mobiledoc.users us ON pat.pid=us.uid
LEFT  JOIN mobiledoc.visitstscodes v  ON enc.STATUS = v.code
WHERE pat.pid <> 8663
AND pat.pid <> 50
AND (enc.ClaimReq = 0 or v.NonBillable = 0) 
AND (v.status = ''Check Out'' or v.status IS NULL)'
)


SELECT
	pt.patient_id,
	app.location_id,
	app.enc_date,
	ROW_NUMBER() OVER(PARTITION BY pt.patient_id,app.location_id ORDER BY app.enc_date ASC) AS rowNum
INTO #mh_cleanup
FROM #patient_temp pt
LEFT JOIN dbo.data_appointment_ecw_etl app ON app.person_id = pt.patient_id
											AND app.nbr_bill_enc = 1
											AND CAST(app.enc_date AS DATE) > DATEADD(MONTH, -6, GETDATE())


 SELECT 
	IDENTITY(INT,1,1) AS ecw_patient_key,
	t.*,
	CASE
		WHEN t.med_home_id_orig = 0 THEN
			(SELECT TOP 1
				location_id
			FROM #mh_cleanup mh
			WHERE mh.patient_id = t.patient_id
			ORDER BY mh.rowNum DESC)
		ELSE t.med_home_id_orig
	END
		AS med_home_id,
	fd.date AS first_enc_date
INTO dbo.data_patient_ecw
FROM #patient_temp t
LEFT JOIN #first_date_clean fd ON (fd.uid = t.patient_id AND fd.rowNum = 1)

--Clean out garbage values which only appear once, and have a bogus encounter date
DELETE FROM dbo.data_patient_ecw WHERE first_enc_date = '3000-01-01'




END
GO
