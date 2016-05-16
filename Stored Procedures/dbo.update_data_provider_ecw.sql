SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <March 21, 2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_provider_ecw]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('dbo.data_provider_ecw') IS NOT NULL
		DROP TABLE dbo.data_provider_ecw

	IF OBJECT_ID('tempdb..#provider_temp') IS NOT NULL
		DROP TABLE #provider_temp

 SELECT * INTO #provider_temp
 FROM OPENQUERY(ECWDB,   'SELECT  DISTINCT  
	users.uid as provider_id,
	CASE
		WHEN fac.facilitynickname LIKE ''%San Pablo%'' THEN 19
		WHEN fac.facilitynickname LIKE ''%Richmond%'' THEN 4
		WHEN fac.portal_name LIKE  ''%San Pablo%'' THEN 19
		WHEN fac.portal_name LIKE ''%Richmond%'' THEN 4
		WHEN fac.portal_name LIKE ''%ECHS%'' THEN 5
		ELSE doctors.FacilityId 
	END
		AS location_id,
	users.ulname AS provider_last_name ,
	users.ufname AS provider_first_name,
	doctors.speciality,
	doctors.providerCode,
	users.uemail,
	users.upaddress,
	fac.Name AS location_name,
	fac.code AS facility_code,
	fac.facilitynickname AS location_nickname,
	fac.DeleteFlag 
 FROM mobiledoc.users users
 INNER JOIN mobiledoc.doctors doctors  ON  users.uid = doctors.doctorID 
 LEFT JOIN mobiledoc.edi_facilities fac  ON fac.Id = doctors.FacilityId
 WHERE (users.UserType = 1 or users.UserType = 5) 
 AND users.delFlag = 0')


 SELECT 
	IDENTITY(INT,1,1) AS ecw_prov_key,
	t.*
INTO dbo.data_provider_ecw
FROM #provider_temp t

END
GO
