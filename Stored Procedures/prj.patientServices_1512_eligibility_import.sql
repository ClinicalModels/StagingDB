SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [prj].[patientServices_1512_eligibility_import]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 	WITH latestRecords
	AS
	(
		SELECT 
	   [txt_membid]
	  ,[txt_sourcefile]
	  ,[txt_chc]
      ,[txt_company]
      ,[txt_effdate]
      ,[txt_termdate]
      ,[txt_patid]
      ,[txt_plan]
      ,[txt_subssn]
      ,[txt_lastnm]
      ,[txt_firstnm]
      ,[txt_street]
      ,[txt_city]
      ,[txt_zip]
      ,[txt_dob]
      ,[txt_sex]
      ,[txt_phone]
      ,[txt_language]
      ,[txt_mcal10]
      ,[txt_otherid2]
      ,[txt_site]
      ,[txt_hic]
      ,[txt_mcarea]
      ,[txt_mcareb]
      ,[txt_ccs]
      ,[txt_ccsdt]
      ,[txt_cob]
      ,[txt_hfpcopay]
      ,[txt_ac]
      ,[txt_transactionCode]
      ,[txt_transactionDate],
            ROW_NUMBER() OVER (PARTITION BY txt_membid
                        ORDER BY txt_sourcefile DESC) rn
    FROM [Staging_Ghost].[dbo].[staging_ng_eligibility_files_data] 
	)
	
	INSERT INTO [dbo].[staging_ng_eligibility_final_data]
	(
	 [txt_membid]
	,[First_mon_date]
      ,[txt_chc]
      ,[txt_company]
      ,[txt_effdate]
      ,[txt_termdate]
      ,[txt_patid]
      ,[txt_plan]
      ,[txt_subssn]
      ,[txt_lastnm]
      ,[txt_firstnm]
      ,[txt_street]
      ,[txt_city]
      ,[txt_zip]
      ,[txt_dob]
      ,[txt_sex]
      ,[txt_phone]
      ,[txt_language]
      ,[txt_mcal10]
      ,[txt_otherid2]
      ,[txt_site]
      ,[txt_hic]
      ,[txt_mcarea]
      ,[txt_mcareb]
      ,[txt_ccs]
      ,[txt_ccsdt]
      ,[txt_cob]
      ,[txt_hfpcopay]
      ,[txt_ac]
      ,[txt_transactionCode]
      ,[txt_transactionDate])
	SELECT latestRecords.txt_membid
	,latestRecords.txt_sourcefile
	,latestRecords.txt_chc
	,latestRecords.txt_company
	,latestRecords.txt_effdate
	,latestRecords.txt_termdate
	,latestRecords.txt_patid
	,latestRecords.txt_plan
	,latestRecords.txt_subssn
	,latestRecords.txt_lastnm
	,latestRecords.txt_firstnm
	,latestRecords.txt_street
	,latestRecords.txt_city,
	latestRecords.txt_zip
	,latestRecords.txt_dob
	,latestRecords.txt_sex
	,latestRecords.txt_phone
	,latestRecords.txt_language
	,latestRecords.txt_mcal10
	,latestRecords.txt_otherid2,
	latestRecords.txt_site
	,latestRecords.txt_hic
	,latestRecords.txt_mcarea
	,latestRecords.txt_mcareb
	,latestRecords.txt_ccs
	,latestRecords.txt_ccsdt,
	latestRecords.txt_cob
	,latestRecords.txt_hfpcopay
	,latestRecords.txt_ac
	,latestRecords.txt_transactionCode
	,latestRecords.txt_transactionDate
FROM latestRecords
WHERE rn = 1 





















	
	
	
	
	
 -- ORDER BY txt_sourcefile DESC

END
GO
