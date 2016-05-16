SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [prj].[grant_1508_LCCI_Vital_Signs_v1]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




SELECT  pat.person_id ,
        lc.*
INTO    #temp2
FROM    project_LLCI_patients lc
        LEFT JOIN [10.183.0.64].NGProd.dbo.patient pat ON RIGHT('00000000000' + RTRIM(pat.med_rec_nbr), 12) = RIGHT('00000000000'
                                                                                                        + RTRIM(lc.med_rec_nbr),
                                                                                                        12)
        LEFT JOIN [10.183.0.64].NGProd.dbo.person per ON per.person_id = pat.person_id;





WITH    vitals
          AS ( SELECT   [person_id] ,
                        CAST(create_timestamp AS DATE) AS BP_date ,
                        [bp_systolic] AS bp_sys ,
                        [bp_diastolic] AS bp_dia ,
                        ROW_NUMBER() OVER ( PARTITION BY person_id, CONVERT(CHAR(8), create_timestamp, 112) ORDER BY create_timestamp DESC ) AS Recency
               FROM     [10.183.0.94].NGProd.dbo.[vital_signs_]
             )
    SELECT  pv.person_id ,
            pv.BP_date ,
            bp_sys ,
            pv.bp_dia ,
            pd.Fullname ,
            pd.enrollment_date ,
            pd.last_service_date ,
            DATEDIFF(d, pd.enrollment_date, pv.BP_date) AS d_from_enroll ,
            DATEDIFF(d, pd.last_service_date, pv.BP_date) AS d_from_lastservice ,
            DATEDIFF(d, pd.enrollment_date, pd.last_service_date) AS total_days_in_program ,
            CASE WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 0
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) > 0 THEN '0 - Pre-enrollment'
                 WHEN DATEDIFF(d, pv.BP_date, pd.last_service_date) < 0 THEN '8 - Post Program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) >= 0
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 31 THEN '1 - 0-30 days since enrollment'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) > 30
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 61 THEN '2 - 31-60 days since enrollment'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) > 60
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 91 THEN '3 - 61-90 days since enrollment'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) > 90
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 121 THEN '4 - 91-120 days since enrollment'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) > 120
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 151 THEN '5 - 121-150 days since enrollment'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) > 150
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 181 THEN '6 - 151-180 days since enrollment'
                 WHEN DATEDIFF(d, pd.enrollment_date, pv.BP_date) > 180
                      AND DATEDIFF(d, pv.BP_date, pd.last_service_date) >= 0 THEN '7 - >180 days since enrollment'
            END AS txt_d_from_enroll ,
            CASE WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) >= 0
                      AND DATEDIFF(d, pd.enrollment_date, pd.last_service_date) < 31 THEN '1 - 0-30 days in program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) > 30
                      AND DATEDIFF(d, pd.enrollment_date, pd.last_service_date) < 61 THEN '2 - 31-60 days in program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) > 60
                      AND DATEDIFF(d, pd.enrollment_date, pd.last_service_date) < 91 THEN '3 - 61-90 days in program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) > 90
                      AND DATEDIFF(d, pd.enrollment_date, pd.last_service_date) < 121 THEN '4 - 91-120 days in program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) > 120
                      AND DATEDIFF(d, pd.enrollment_date, pd.last_service_date) < 151 THEN '5 - 121-150 days in program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) > 150
                      AND DATEDIFF(d, pd.enrollment_date, pd.last_service_date) < 181 THEN '6 - 151-180 days in program'
                 WHEN DATEDIFF(d, pd.enrollment_date, pd.last_service_date) > 180 THEN '7 - >180 days in program'
                 ELSE 'Bad Data'
            END AS txt_total_days_in_program ,
            CASE WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) <= 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) >= 0 THEN '1 - In Program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) < 0
                      AND DATEDIFF(d, pd.enrollment_date, pv.BP_date) < 0 THEN '0 - Pre Program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) >= 1
                      AND DATEDIFF(d, pd.last_service_date, pv.BP_date) < 31 THEN '2 - 0-30 days post program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) > 30
                      AND DATEDIFF(d, pd.last_service_date, pv.BP_date) < 61 THEN '3 - 31-60 days post program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) > 60
                      AND DATEDIFF(d, pd.last_service_date, pv.BP_date) < 91 THEN '4 - 61-90 days post program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) > 90
                      AND DATEDIFF(d, pd.last_service_date, pv.BP_date) < 121 THEN '5 - 91-120 days post program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) > 120
                      AND DATEDIFF(d, pd.last_service_date, pv.BP_date) < 151 THEN '6 - 121-150 days post program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) > 150
                      AND DATEDIFF(d, pd.last_service_date, pv.BP_date) < 181 THEN '7 - 151-180 days post program'
                 WHEN DATEDIFF(d, pd.last_service_date, pv.BP_date) > 180 THEN '8 - >180 days post program'
            END AS txt_d_from_lastservice
    FROM    #temp2 pd
            LEFT JOIN ( SELECT  person_id ,
                                bp_sys ,
                                bp_dia ,
                                vitals.BP_date
                        FROM    vitals
                        WHERE   Recency = 1
                      ) pv ON pd.person_id = pv.person_id
    WHERE   pv.bp_dia IS NOT NULL;


DROP TABLE #temp2;
END
GO
