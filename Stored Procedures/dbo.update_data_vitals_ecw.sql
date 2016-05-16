SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_vitals_ecw]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF OBJECT_ID('dbo.data_vital_signs_ecw') IS NOT NULL
		DROP TABLE dbo.data_vital_signs_ecw

	IF OBJECT_ID('tempdb..#temp_vitals') IS NOT NULL
		DROP TABLE #temp_vitals

    SELECT * INTO #temp_vitals
	FROM OPENQUERY(ECWDB, 
	'SELECT  DISTINCT  
	enc.encounterID AS  encounter_id , 
	enc.patientID AS  person_id , 
	CASE  
		WHEN bmi.vitalID = 170669 THEN  bmi.value 
		ELSE '''' 
	END  
		AS BMI , 
	CASE  
		WHEN bp.vitalID = 212 THEN  bp.value 
		ELSE '''' 
	END  
		AS bp_all , 
	CASE  
		WHEN ht.vitalID = 215 THEN  ht.value 
		ELSE '''' 
	END  
		AS height_inches ,
	case  
		WHEN wt.vitalID = 216 THEN  wt.value
		 else '''' 
	END  
		AS weight_lb,
	date_format(wt.UpdatedTime,''%Y-%m-%d'') AS modify_date,
	date_format(enc.date, ''%Y-%m-%d'') AS encounter_date
 FROM (((mobiledoc.enc enc 
 LEFT OUTER JOIN mobiledoc.vitals ht on enc.encounterID = ht.encounterID and 215 = ht.vitalID) 
 LEFT OUTER JOIN mobiledoc.vitals bmi on enc.encounterID = bmi.encounterID AND 170669 = bmi.vitalID) 
 LEFT OUTER JOIN mobiledoc.vitals bp on enc.encounterID = bp.encounterID and 212 = bp.vitalID) 
 LEFT OUTER JOIN mobiledoc.vitals wt on enc.encounterID = wt.encounterID and 216 = wt.vitalID
 where enc.patientID <> 8663 
 AND enc.VisitType <> ''PTDASH'' 
 AND enc.deleteFlag = 0')


 SELECT
	v.encounter_id,
	v.person_id,
	Try_CAST( LEFT(SUBSTRING(weight_lb, PATINDEX('%[0-9.]%', weight_lb), 8000),
		PATINDEX('%[^0-9.]%', SUBSTRING(weight_lb, PATINDEX('%[0-9.]%', weight_lb), 8000) + 'X') -1) AS DECIMAL(10,2)) 
		AS weight_lb_clean,
	Try_CAST( LEFT(SUBSTRING(BMI, PATINDEX('%[0-9.]%', BMI), 8000),
		PATINDEX('%[^0-9.]%', SUBSTRING(BMI, PATINDEX('%[0-9.]%', BMI), 8000) + 'X') -1) AS DECIMAL(10,2)) 
		AS bmi_clean,
	Try_CAST( LEFT(SUBSTRING(height_inches, PATINDEX('%[0-9.]%', height_inches), 8000),
		PATINDEX('%[^0-9.]%', SUBSTRING(height_inches, PATINDEX('%[0-9.]%', height_inches), 8000) + 'X') -1) AS DECIMAL(10,2)) 
		AS height_inches_clean,
	
	--ECW stores bp as sys/diast, so it has to be split into its substrings
	CASE
		WHEN CHARINDEX('/', v.bp_all) > 0 THEN LEFT(v.bp_all, CHARINDEX('/', v.bp_all, 0)-1) 
		ELSE NULL
	END
		AS bp_syst,
	CASE
		WHEN CHARINDEX('/', v.bp_all) > 0 THEN RIGHT(v.bp_all, CHARINDEX('/', REVERSE(v.bp_all), 0)-1)
		ELSE NULL
	END
		AS bp_diast,

	----ECW vitals don't have a created timestamp, so one is manufactured
	CAST(COALESCE(v.modify_date,v.encounter_date) AS DATETIME) AS create_timestamp,
	ROW_NUMBER() OVER(PARTITION BY v.person_id, COALESCE(v.modify_date,v.encounter_date) ORDER BY v.encounter_date DESC) AS recency_day,
	ROW_NUMBER() OVER(PARTITION BY v.person_id ORDER BY v.encounter_date DESC) AS recency_all
INTO #vitals_clean	  
FROM #temp_vitals v


SELECT
	v.*,
	Try_CAST( LEFT(SUBSTRING(bp_syst, PATINDEX('%[0-9.]%', bp_syst), 8000),
		PATINDEX('%[^0-9.]%', SUBSTRING(bp_syst, PATINDEX('%[0-9.]%', bp_syst), 8000) + 'X') -1) AS DECIMAL(10,2)) 
		AS bp_syst_clean,
	Try_CAST( LEFT(SUBSTRING(bp_diast, PATINDEX('%[0-9.]%', bp_diast), 8000),
		PATINDEX('%[^0-9.]%', SUBSTRING(bp_diast, PATINDEX('%[0-9.]%', bp_diast), 8000) + 'X') -1) AS DECIMAL(10,2)) 
		AS bp_diast_clean,
		CASE
		WHEN height_inches_clean IS NOT NULL THEN height_inches_clean * 2.54
		ELSE NULL 
	END
		 AS height_cm_calc,
	CASE 
		WHEN weight_lb_clean IS NOT NULL THEN weight_lb_clean * 0.453592
		ELSE NULL
	END
		AS weight_kg_calc,
	LEAD(create_timestamp, 1) OVER ( PARTITION BY person_id ORDER BY create_timestamp ASC ) AS NextDate
INTO dbo.data_vital_signs_ecw
FROM #vitals_clean v

--Delete any rows which contain no vital signs at all
DELETE FROM dbo.data_vital_signs_ecw
WHERE weight_lb_clean IS NULL 
AND bmi_clean IS NULL
AND height_inches_clean IS NULL
AND bp_syst_clean IS NULL
AND bp_diast_clean IS NULL



END
GO
