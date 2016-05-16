SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ben Mansalis
-- Create date: 7/2015
-- Description:	The purpose of the procedure is to create a slowly changing dimensions
--              of key attributes for demographic analysis over time
-- Dependency:  data_pharmacy
--              data_encounter
--              data_time 
-- Future:
-- Make sure to add foreign and primary key constraints and integer keys
-- Bring in change of location or pcp from sig_events table

-- =============================================

CREATE PROCEDURE [dwh].[update_data_person_month]
AS
    BEGIN


        SET ANSI_NULLS ON;
        SET QUOTED_IDENTIFIER ON;

        IF OBJECT_ID('dwh.data_person_month') IS NOT NULL
            DROP TABLE dwh.data_person_month;




        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);

        SET @build_dt_start = CONVERT(VARCHAR(8), GETDATE(), 112); --This routine will build current and hx data from begin to end date 
        SET @build_dt_end = CONVERT(VARCHAR(8), GETDATE(), 112);
		SET @build_dt_start = '20100301';


;WITH all_patients AS (

        SELECT  
                per.[person_id] AS person_id ,
                [primarycare_prov_id] AS pcp_id_cur ,
                NULL AS pcp_id_day ,
                tim.first_mon_date ,
                [date_of_birth] ,
                CASE 
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= tim.first_mon_date
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > tim.first_mon_date
                               THEN DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), tim.first_mon_date) 
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN NULL
                               ELSE DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), tim.first_mon_date)
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= tim.first_mon_date
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > tim.first_mon_date
                               THEN DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), tim.first_mon_date) 
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN NULL
                               ELSE DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), tim.first_mon_date)
                          END
                END AS MemberMonths ,
                CASE  
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= tim.first_mon_date
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > tim.first_mon_date
                               THEN IIF(DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), tim.first_mon_date) <= 1, 1, 0)-- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 0
                               ELSE IIF(DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), tim.first_mon_date) <= 1, 1, 0)
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= tim.first_mon_date
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > tim.first_mon_date
                               THEN IIF(DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), tim.first_mon_date) <= 1, 1, 0)-- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 0
                               ELSE IIF(DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), tim.first_mon_date) <= 1, 1, 0)
                          END
                END AS Nbr_new_pt ,
                CASE  
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= tim.first_mon_date THEN 
		            --deal with expired patients 
                          IIF(DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), tim.first_mon_date) > 0, 1, 0)--This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= tim.first_mon_date
                     THEN IIF(DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), tim.first_mon_date) > 0, 1, 0)
                     ELSE 0
                END AS Nbr_pt_ever_enrolled ,
                CASE 
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= tim.first_mon_date
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date (not dead yet) and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > tim.first_mon_date THEN 0
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 1
                               ELSE 0
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= tim.first_mon_date
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > tim.first_mon_date THEN 0
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 1
                               ELSE 0
                          END
                END AS nbr_pt_deceased ,
                CASE WHEN ISDATE(per.[expired_date]) = 1
                     THEN CASE WHEN CAST(CONVERT(CHAR(6), per.[expired_date], 112) + '01' AS DATE) = tim.first_mon_date
                               THEN 1
                               ELSE 0
                          END
                END AS nbr_pt_deceased_this_month ,
                CASE WHEN ud_demo3_id = '8125418E-7B63-4D4C-901B-63C0BFE95A53'
                     THEN CAST('CE01BF12-1DC0-4C09-9694-474C8EEA8327' AS UNIQUEIDENTIFIER)   --LifeLong Ashby Health Center
                     WHEN ud_demo3_id = 'D3C9A792-EA26-4A26-9336-94399832CB79'
                     THEN CAST('E4CDE909-10FB-4B3E-8AEE-27298138F4AF' AS UNIQUEIDENTIFIER)     --LifeLong Berkeley Primary Care
                     WHEN ud_demo3_id = '962C60B9-D7E0-452A-BF17-4A6ED6023E36'
                     THEN CAST('B9202BC6-62BF-43CB-A63D-B0F94159B6A3' AS UNIQUEIDENTIFIER)   --LifeLong Brookside Center
                     WHEN ud_demo3_id = '578B940F-EC70-4D1D-9DEB-A2A3AE671719'
                     THEN CAST('6EBE563F-39A4-49C1-936A-B6966CECFF7C' AS UNIQUEIDENTIFIER)   --LifeLong Dental Center
                     WHEN ud_demo3_id = '453F0729-40D3-4CD8-BC8D-F30E3865A882'
                     THEN CAST('9567D24D-2B4F-402B-A7CA-0546A85D8CF3' AS UNIQUEIDENTIFIER)   --LifeLong Downtown Oakland Clinic
                     WHEN ud_demo3_id = 'EBAF047B-B263-4489-879C-034DB96DA74D'
                     THEN CAST('1A0FECF5-00C2-4E16-BFDA-D529166A3DC8' AS UNIQUEIDENTIFIER)    --LifeLong East Oakland
                     WHEN ud_demo3_id = '76BD59E7-60AE-4160-B739-29BCEC6A7EA1'
                     THEN CAST('1A0FECF5-00C2-4E16-BFDA-D529166A3DC8' AS UNIQUEIDENTIFIER)    --LifeLong East Oakland ADHC
                     WHEN ud_demo3_id = 'DE5D740A-A20C-4D45-A38F-AF00F9E99653'
                     THEN CAST('A6BCC717-C0C9-454A-90FC-1EF010256FE4' AS UNIQUEIDENTIFIER)    --LifeLong Eastmont Center
                     WHEN ud_demo3_id = '3E675DED-89FE-4FDA-A61B-2D02668FC98D'
                     THEN CAST('E9C81D34-ECF1-4851-B3E3-6A01E28AEF84' AS UNIQUEIDENTIFIER)    --LifeLong Elmhurst/Alliance Academy
                     WHEN ud_demo3_id = '58FEA7B9-61C9-43CA-8A24-37BE9619727D'
                     THEN CAST('A8DFDE55-EEB0-4353-ACC5-AC39B792841D' AS UNIQUEIDENTIFIER)    --LifeLong EO Wellness Center
                     WHEN ud_demo3_id = 'C138486D-4C26-4D92-B553-E95400E197BF'
                     THEN CAST('6678B8DA-C10E-442C-97DC-D40979D7C2DF' AS UNIQUEIDENTIFIER)    --LifeLong Howard Daniel Clinic
                     WHEN ud_demo3_id = '0E88F95B-4790-4DB4-AF36-D025593AAB07'
                     THEN CAST('C2678A20-C0B9-46C6-8E10-7E1ACCB6D826' AS UNIQUEIDENTIFIER)   --LifeLong Jenkins Pediatric Center
                     WHEN ud_demo3_id = 'D1521C2F-3A7A-41FA-B5FA-7BBB0715A9D0'
                     THEN CAST('8BAD2EFD-B455-43B7-AA73-687ACFFF789E' AS UNIQUEIDENTIFIER)   --LifeLong Over 60 Health Center
                     WHEN ud_demo3_id = '621890E1-B2EC-4AFB-9752-6C77063D461B'
                     THEN CAST('18ABDAF4-C538-4E07-9C02-07CAA576F49B' AS UNIQUEIDENTIFIER)   --LifeLong Richmond Clinic
                     WHEN ud_demo3_id = '09C57FBA-16D2-4828-B884-E7B9BCBD8252'
                     THEN CAST('EAE9576F-6B6F-46F0-98AC-7D057B27E18B' AS UNIQUEIDENTIFIER)   --LifeLong Rosa Parks School
                     WHEN ud_demo3_id = '1DFC42E0-321F-43DD-8F33-34BB4C753BCE'
                     THEN CAST('8BAD2EFD-B455-43B7-AA73-687ACFFF789E' AS UNIQUEIDENTIFIER)    --LifeLong SNF-Nursing Over 60
                     WHEN ud_demo3_id = 'FC9346CE-EB14-4060-B548-472216347BA0'
                     THEN CAST('0E6B0497-44E6-4C1C-AC3C-668999AA6B3F' AS UNIQUEIDENTIFIER)    --LifeLong Supportive Housing Project
                     WHEN ud_demo3_id = 'F6EC14C6-8ECF-4A0E-9663-FF79F88D3D51'
                     THEN CAST('4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD' AS UNIQUEIDENTIFIER)   --LifeLong Thunder Road
                     WHEN ud_demo3_id = '131B16DE-F576-4028-AC08-158470F42599'
                     THEN CAST('F62ED25A-6AC2-4355-A6E4-72B1326F39AF' AS UNIQUEIDENTIFIER)   --LifeLong West Berkeley Family Practice
                     WHEN ud_demo3_id = 'D305AD2A-FBA9-4F77-9D03-4DFDEE33662C'
                     THEN CAST('5A972255-18DD-4F52-B4D2-F10C12C8F08F' AS UNIQUEIDENTIFIER)    --LifeLong West Oakland Middle School
                     WHEN ud_demo3_id = '4C03ADA2-5DF5-4953-846C-29E9CBE0B418' THEN CAST(NULL AS UNIQUEIDENTIFIER)     --Unknown Clinic
                     WHEN ud_demo3_id = 'F3D7C3B4-F432-4292-88EC-58D09AC22D73' THEN CAST(NULL AS UNIQUEIDENTIFIER)    --LifeLong Marin Adult Day Center
                     ELSE CAST(NULL AS UNIQUEIDENTIFIER)
                END AS location_id
        FROM    [10.183.0.94].NGProd.dbo.[person] per
                LEFT JOIN [10.183.0.94].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.[patient] pat ON per.person_id = pat.person_id
                CROSS JOIN ( SELECT DISTINCT
                                    first_mon_date
                             FROM   [Staging_Ghost].dwh.data_time
                             WHERE  first_mon_date >= CAST(@build_dt_start AS DATETIME)
                                    AND first_mon_date <= CAST(@build_dt_end AS DATETIME)
                           ) tim

)
, patients_w_billable_enc AS (
--Find out if the person had a billable encounter during the month

        SELECT  enc.person_id AS person_id ,
                enc.first_mon_date,
                SUM(billable_enc_ct) AS [billable_enc_ct] 
      
		 FROM    [Staging_Ghost].[dwh].data_encounter enc
          
        WHERE  ( enc.enc_bill_date >= @build_dt_start
                      AND enc.enc_bill_date <= @build_dt_end) AND  enc.billable_enc_ct =1
                    
        GROUP BY enc.person_id , enc.first_mon_date
 )               
        
--Find out if the person had a controlled rx during the month
 , patients_controlled_rx   AS (
           SELECT  person_id, 
			       first_mon_date, COUNT(DISTINCT ndc) AS ct_controlled
		      FROM    [Staging_Ghost].[dwh].[data_pharmacy]
                       WHERE   drug_dea_class >= 2 AND 
 (drug_name LIKE '%vicodin%' OR
 drug_name LIKE '%Vicoprofen%' OR
 drug_name LIKE '%Percocet%' OR
 drug_name LIKE '%Percodan%' OR
 drug_name LIKE '%oxymorphone%' OR

 drug_name LIKE '%OxyContin%' OR
 drug_name LIKE '%oxycodone%' OR
 drug_name LIKE '%Norco%' OR
 drug_name LIKE '%MS Contin%' OR
 drug_name LIKE '%morphine%' OR
 drug_name LIKE '%methadone%' OR
 drug_name LIKE '%Lortab%' OR
 drug_name LIKE '%hydromorphone%' OR
 drug_name LIKE '%hydrocodone%' OR
 drug_name LIKE '%Hycet%' OR
 drug_name LIKE '%Vicoprofen%' OR
 drug_name LIKE '%vicodin%' OR
 drug_name LIKE '%fentanyl%' OR

 drug_name LIKE '%Dilaudid%' )
                    GROUP BY person_id,first_mon_date   )
									
		  				     
 
        SELECT  IDENTITY( INT, 1, 1 )  AS per_mon_id ,
		                 ap.* ,
                CASE WHEN nbr_pt_deceased != 1
                          AND MemberMonths >= 1
                          AND ap.date_of_birth IS NOT NULL
                          THEN DATEDIFF(YY, CAST(ap.[date_of_birth] AS DATE), CAST(ap.first_mon_date AS DATE))
                     ELSE NULL
                END AS CurMon_Pt_Age ,
                


                IIF(( ISNULL(ct_controlled, 0)
				      + ISNULL(LAG(ct_controlled, 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      ) > 0, 1, 0) AS nbr_chronic_pain_12m ,


					  
                IIF(( ISNULL(ct_controlled, 0)
				      + ISNULL(LAG(ct_controlled, 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ), 0)
                    ) > 0, 1, 0) AS nbr_chronic_pain_6m ,





                IIF(( ISNULL([billable_enc_ct], 0)
                      + ISNULL(LAG([billable_enc_ct], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                       ) > 0, 1, 0) AS nbr_pt_act_3m ,

                IIF(( ISNULL([billable_enc_ct], 0)
                      + ISNULL(LAG([billable_enc_ct], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                       ) > 0, 1, 0) AS nbr_pt_act_6m ,
                IIF(( ISNULL([billable_enc_ct], 0)
                      + ISNULL(LAG([billable_enc_ct], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                       ) > 0, 1, 0) AS nbr_pt_act_12m ,
                IIF(( ISNULL([billable_enc_ct], 0)
                      + ISNULL(LAG([billable_enc_ct], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 12) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 13) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 14) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 15) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 16) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 17) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                       ) > 0, 1, 0) AS nbr_pt_act_18m ,
                IIF(( ISNULL([billable_enc_ct], 0)
                      + ISNULL(LAG([billable_enc_ct], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 12) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 13) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 14) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 15) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 16) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 17) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 18) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 19) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 20) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 21) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 22) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                      + ISNULL(LAG([billable_enc_ct], 23) OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC ),
                               0)
                       ) > 0, 1, 0) AS nbr_pt_act_24m ,
                rank_order = ROW_NUMBER() OVER ( PARTITION BY ap.person_id ORDER BY ap.first_mon_date ASC )
        
		
		
		
		INTO    dwh.data_person_month
        FROM    all_patients ap
                 LEFT JOIN patients_w_billable_enc ac ON ap.person_id = ac.person_id
                                                    AND ac.first_mon_date = ap.first_mon_date
                LEFT JOIN patients_controlled_rx ar ON ap.person_id = ar.person_id
                                                        AND ar.first_mon_date = ap.first_mon_date;


    END;

	/*SELECT 
       [sig_msg]
      ,[post_mod]
      ,[create_timestamp]
      ,[created_by]
      ,[modify_timestamp]
      ,[modified_by]
      ,[row_timestamp]
      ,[group_id]
      ,[create_timestamp_tz]
      ,[modify_timestamp_tz]
  FROM [NGProd].[dbo].[sig_events] WHERE sig_msg like '%Medical Home%' -- AND pre_mod LIKE '%searls%'
*/
GO
