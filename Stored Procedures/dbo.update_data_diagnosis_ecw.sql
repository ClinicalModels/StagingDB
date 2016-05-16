SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_diagnosis_ecw]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF OBJECT_ID('dbo.data_diagnosis_ecw') IS NOT NULL
		DROP TABLE dbo.data_diagnosis_ecw

    SELECT * INTO #temp_diag
FROM OPENQUERY(ECWDB, '
		 SELECT
			enc.patientID as person_id_ecw,
			enc.encounterID as encounter_id_ecw,
			det.value AS icd_code,
			items.itemName as diagnosis_description,
			date_format(x.StartDate,''%Y-%m-%d'') as start_date,
			date_format(x.StopDate, ''%Y-%m-%d'') as stop_date
		 FROM (((mobiledoc.enc enc 
		 INNER JOIN mobiledoc.diagnosis diag on enc.encounterID = diag.EncounterId)
		 INNER JOIN mobiledoc.items items on diag.ItemId = items.itemID)
		 INNER JOIN mobiledoc.itemdetail det on det.itemID = diag.ItemId and det.propID = 13)
		 LEFT OUTER JOIN mobiledoc.oldrxmain x on diag.ItemId = x.AssessId and diag.EncounterId = x.encounterId
		 WHERE enc.patientID <> 8663')

SELECT
	d.*,
	CASE
			WHEN icd_code LIKE '250%' THEN 'Diabetes'
			WHEN icd_code LIKE 'E10.%' THEN 'Diabetes'
			WHEN icd_code LIKE 'E11.%' THEN 'Diabetes'
			WHEN icd_code LIKE '401%' THEN 'Hypertension'
			WHEN icd_code LIKE '402%' THEN 'Hypertension'
			WHEN icd_code LIKE 'I10.%' THEN 'Hypertension'
			WHEN icd_code LIKE 'I11.%' THEN 'Hypertension'
			WHEN icd_code LIKE 'B20%'THEN 'HIV'
			WHEN icd_code LIKE 'B21%'THEN 'HIV'
			WHEN icd_code LIKE 'B22%'THEN 'HIV'
			WHEN icd_code LIKE 'B23%'THEN 'HIV'
			WHEN icd_code LIKE 'B24%'THEN 'HIV'
			WHEN icd_code LIKE '042%'THEN 'HIV'
			WHEN icd_code LIKE 'V08%'THEN 'HIV' --Asymptomatic HIV
			WHEN icd_code LIKE '079.53'THEN 'HIV' --For HIV-2
			--WHEN d.diagnosis_code_id LIKE '795.71' THEN 1 --Inconclusive HIV Test, possibly requires its own flag
			ELSE NULL
	END
		AS chronic_dx_label,
	LEFT(icd_code, 9) AS icd_code_trimmed,
	(RTRIM(icd_code) + '-' + diagnosis_description) AS dx_enc,
	ROW_NUMBER() OVER(PARTITION BY encounter_id_ecw ORDER BY start_date ASC) AS dx_enc_rank
INTO dbo.data_diagnosis_ecw
FROM #temp_diag d

END
GO
