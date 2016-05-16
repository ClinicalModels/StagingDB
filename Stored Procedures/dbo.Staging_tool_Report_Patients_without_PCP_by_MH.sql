SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Staging_tool_Report_Patients_without_PCP_by_MH]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT ml.mstr_list_item_desc ,
        COUNT(*) AS QTY
 FROM   [10.183.0.94].NGProd.dbo.person per1
        INNER JOIN ( SELECT distinct enc.person_id
                     FROM   [10.183.0.94].NGProd.dbo.patient_encounter enc
                            LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON per.person_id = enc.person_id
                     WHERE  enc.billable_ind = 'Y'
                            AND per.expired_ind != 'Y'
                            AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 18
                            AND per.primarycare_prov_id IS NULL
                   ) per2 ON per2.person_id = per1.person_id
        LEFT JOIN [10.183.0.94].NGProd.dbo.[person_ud] ud ON per1.person_id = ud.person_id
        INNER JOIN [10.183.0.94].NGProd.dbo.[mstr_lists] ml ON ud.ud_demo3_id = ml.mstr_list_item_id
 GROUP BY ml.mstr_list_item_desc;



END
GO
