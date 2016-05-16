SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_data_person]
AS
    BEGIN
-- PCP reassigment script

-- add primary site and PCP slots per week to provider table in datamart
-- create a table of relative PCP appointment time available for providers panels and lanuages spoken by provider
-- create a table of relative existing normalized empanelment by PCP at the site
-- create identify from and to providers
-- Create a table of patients in the From category with language and provider who has seen patient most minimum of 2 times in the past 18 months (Most Freq)
-- First pass assign new PCP based on language requirements
-- 2nd pass assign new PCP if there is no Most Freq PCP based on relative FTE accounting for existing assignemnts

--create schema dwh

        SET ANSI_NULLS ON;

        SET QUOTED_IDENTIFIER ON;


        IF OBJECT_ID('dwh.data_person') IS NOT NULL
            DROP TABLE dwh.data_person;
   
        SELECT  per.person_id ,
                CASE WHEN [first_office_enc_date] IS NOT NULL
                          AND [first_office_enc_date] != ''
                     THEN SUBSTRING(CONVERT(CHAR(8), [first_office_enc_date], 112), 1, 6)
                     ELSE SUBSTRING(CONVERT(CHAR(8), per.[create_timestamp], 112), 1, 6)
                END AS VintageYM ,
                per.[create_timestamp] AS Person_rec_Creation_Dt ,
                ISNULL([expired_ind], '') AS Deceased ,
                CASE WHEN ISNULL([expired_date], '') != '' THEN CAST([expired_date] AS DATE)
                     ELSE NULL
                END AS Deceased_dt ,
                CASE WHEN ISNULL([first_office_enc_date], '') != '' THEN CAST([first_office_enc_date] AS DATE)
                     ELSE NULL
                END AS [first_office_enc_date] ,
                CASE WHEN ISNULL([last_office_enc_date], '') != '' THEN CAST([last_office_enc_date] AS DATE)
                     ELSE NULL
                END AS [last_office_enc_date] ,
                ISNULL(first_name, '') AS First_name ,
                ISNULL([last_name], '') AS [last_name] ,
                CONCAT(ISNULL(first_name, ''), ' ', ISNULL([last_name], '')) AS full_Name ,
                ISNULL([middle_name], '') AS middle_name ,
                ISNULL([suffix], '') AS [suffix] ,
                ISNULL([prefix], '') AS [prefix] ,
                ISNULL([degree], '') AS [degree] ,
                ISNULL([address_line_1], '') AS [address_line_1] ,
                ISNULL([address_line_2], '') AS [address_line_2] ,
                ISNULL([city], '') AS [city] ,
                ISNULL([state], '') AS state ,
                ISNULL([zip], '') AS zip ,
                ISNULL([country], '') AS country ,
                ISNULL([county], '') AS county ,
                ISNULL([home_phone], '') AS home_phone ,
                ISNULL([day_phone], '') AS day_phone ,
                ISNULL([alt_phone], '') AS alt_phone ,
                CASE WHEN ISNULL([date_of_birth], '') != '' THEN CAST([date_of_birth] AS DATE)
                     ELSE NULL
                END AS DOB ,
                CASE WHEN ISNULL([date_of_birth], '') != '' THEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE())
                     ELSE NULL
                END AS Age_Nbr_Today
	  --Age
                ,
                CASE WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 18 THEN '0-18 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 29 THEN '19-29 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 39 THEN '30-39 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 49 THEN '40-49 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 59 THEN '50-59 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 64 THEN '60-64 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 74 THEN '65-74 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 79 THEN '75-79 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 89 THEN '80-89 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) <= 99 THEN '90-99 Years'
                     WHEN DATEDIFF(YY, CAST([date_of_birth] AS DATE), GETDATE()) >= 100 THEN '>100 Years'
                     ELSE ''
                END AS Age_Range_Today ,
                ISNULL([sex], '') AS sex ,
                ISNULL([ssn], '') AS ssn ,
                ISNULL([marital_status], '') AS marital_status ,
                ISNULL([smoker_ind], '') AS smoker ,
                ISNULL([veteran_ind], '') AS veteran ,
                ISNULL([race], '') AS race ,
                ISNULL([language], '') AS language ,
                ISNULL([student_status], '') AS student_status ,
                [primarycare_prov_id] AS pcp_id_today ,
                ISNULL([primarycare_prov_name], '') AS pcp_name_today ,
                ISNULL([ethnicity], '') AS ethinicity ,
                ISNULL([med_rec_nbr], '') AS med_rec_nbr ,
                CASE 
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= GETDATE()
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > GETDATE()
                               THEN DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), GETDATE()) 
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN NULL
                               ELSE DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), GETDATE())
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= GETDATE()
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > GETDATE()
                               THEN DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), GETDATE()) 
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN NULL
                               ELSE DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), GETDATE())
                          END
                END AS MemberMonths ,
                CASE WHEN ud.ud_demo3_id = '8125418E-7B63-4D4C-901B-63C0BFE95A53'
                     THEN CAST('CE01BF12-1DC0-4C09-9694-474C8EEA8327' AS UNIQUEIDENTIFIER)   --LifeLong Ashby Health Center
                     WHEN ud.ud_demo3_id = 'D3C9A792-EA26-4A26-9336-94399832CB79'
                     THEN CAST('E4CDE909-10FB-4B3E-8AEE-27298138F4AF' AS UNIQUEIDENTIFIER)     --LifeLong Berkeley Primary Care
                     WHEN ud.ud_demo3_id = '962C60B9-D7E0-452A-BF17-4A6ED6023E36'
                     THEN CAST('B9202BC6-62BF-43CB-A63D-B0F94159B6A3' AS UNIQUEIDENTIFIER)   --LifeLong Brookside Center
                     WHEN ud.ud_demo3_id = '578B940F-EC70-4D1D-9DEB-A2A3AE671719'
                     THEN CAST('6EBE563F-39A4-49C1-936A-B6966CECFF7C' AS UNIQUEIDENTIFIER)   --LifeLong Dental Center
                     WHEN ud.ud_demo3_id = '453F0729-40D3-4CD8-BC8D-F30E3865A882'
                     THEN CAST('9567D24D-2B4F-402B-A7CA-0546A85D8CF3' AS UNIQUEIDENTIFIER)   --LifeLong Downtown Oakland Clinic
                     WHEN ud.ud_demo3_id = 'EBAF047B-B263-4489-879C-034DB96DA74D'
                     THEN CAST('1A0FECF5-00C2-4E16-BFDA-D529166A3DC8' AS UNIQUEIDENTIFIER)    --LifeLong East Oakland
                     WHEN ud.ud_demo3_id = '76BD59E7-60AE-4160-B739-29BCEC6A7EA1'
                     THEN CAST('1A0FECF5-00C2-4E16-BFDA-D529166A3DC8' AS UNIQUEIDENTIFIER)    --LifeLong East Oakland ADHC
                     WHEN ud.ud_demo3_id = 'DE5D740A-A20C-4D45-A38F-AF00F9E99653'
                     THEN CAST('A6BCC717-C0C9-454A-90FC-1EF010256FE4' AS UNIQUEIDENTIFIER)    --LifeLong Eastmont Center
                     WHEN ud.ud_demo3_id = '3E675DED-89FE-4FDA-A61B-2D02668FC98D'
                     THEN CAST('E9C81D34-ECF1-4851-B3E3-6A01E28AEF84' AS UNIQUEIDENTIFIER)    --LifeLong Elmhurst/Alliance Academy
                     WHEN ud.ud_demo3_id = '58FEA7B9-61C9-43CA-8A24-37BE9619727D'
                     THEN CAST('A8DFDE55-EEB0-4353-ACC5-AC39B792841D' AS UNIQUEIDENTIFIER)    --LifeLong EO Wellness Center
                     WHEN ud.ud_demo3_id = 'C138486D-4C26-4D92-B553-E95400E197BF'
                     THEN CAST('6678B8DA-C10E-442C-97DC-D40979D7C2DF' AS UNIQUEIDENTIFIER)    --LifeLong Howard Daniel Clinic
                     WHEN ud.ud_demo3_id = '0E88F95B-4790-4DB4-AF36-D025593AAB07'
                     THEN CAST('C2678A20-C0B9-46C6-8E10-7E1ACCB6D826' AS UNIQUEIDENTIFIER)   --LifeLong Jenkins Pediatric Center
                     WHEN ud.ud_demo3_id = 'D1521C2F-3A7A-41FA-B5FA-7BBB0715A9D0'
                     THEN CAST('8BAD2EFD-B455-43B7-AA73-687ACFFF789E' AS UNIQUEIDENTIFIER)   --LifeLong Over 60 Health Center
                     WHEN ud.ud_demo3_id = '621890E1-B2EC-4AFB-9752-6C77063D461B'
                     THEN CAST('18ABDAF4-C538-4E07-9C02-07CAA576F49B' AS UNIQUEIDENTIFIER)   --LifeLong Richmond Clinic
                     WHEN ud.ud_demo3_id = '09C57FBA-16D2-4828-B884-E7B9BCBD8252'
                     THEN CAST('EAE9576F-6B6F-46F0-98AC-7D057B27E18B' AS UNIQUEIDENTIFIER)   --LifeLong Rosa Parks School
                     WHEN ud.ud_demo3_id = '1DFC42E0-321F-43DD-8F33-34BB4C753BCE'
                     THEN CAST('8BAD2EFD-B455-43B7-AA73-687ACFFF789E' AS UNIQUEIDENTIFIER)    --LifeLong SNF-Nursing Over 60
                     WHEN ud.ud_demo3_id = 'FC9346CE-EB14-4060-B548-472216347BA0'
                     THEN CAST('0E6B0497-44E6-4C1C-AC3C-668999AA6B3F' AS UNIQUEIDENTIFIER)    --LifeLong Supportive Housing Project
                     WHEN ud.ud_demo3_id = 'F6EC14C6-8ECF-4A0E-9663-FF79F88D3D51'
                     THEN CAST('4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD' AS UNIQUEIDENTIFIER)   --LifeLong Thunder Road
                     WHEN ud.ud_demo3_id = '131B16DE-F576-4028-AC08-158470F42599'
                     THEN CAST('F62ED25A-6AC2-4355-A6E4-72B1326F39AF' AS UNIQUEIDENTIFIER)   --LifeLong West Berkeley Family Practice
                     WHEN ud.ud_demo3_id = 'D305AD2A-FBA9-4F77-9D03-4DFDEE33662C'
                     THEN CAST('5A972255-18DD-4F52-B4D2-F10C12C8F08F' AS UNIQUEIDENTIFIER)    --LifeLong West Oakland Middle School
                     WHEN ud.ud_demo3_id = '4C03ADA2-5DF5-4953-846C-29E9CBE0B418' THEN CAST(NULL AS UNIQUEIDENTIFIER)     --Unknown Clinic
                     WHEN ud.ud_demo3_id = 'F3D7C3B4-F432-4292-88EC-58D09AC22D73' THEN CAST(NULL AS UNIQUEIDENTIFIER)    --LifeLong Marin Adult Day Center
                     ELSE CAST(NULL AS UNIQUEIDENTIFIER)
                END AS location_id ,
                ml.[mstr_list_item_desc] AS location_name_UD ,
                sdp.Nbr_new_pt AS Is_New_Patient ,
                sdp.nbr_pt_act_3m AS Is_act_3m ,
                sdp.nbr_pt_act_6m AS Is_act_6m ,
                sdp.nbr_pt_act_12m AS Is_act_12m ,
                sdp.nbr_pt_act_18m AS Is_act_18m ,
                sdp.nbr_pt_act_24m AS Is_act_24m
        INTO    dwh.data_person
        FROM    [10.183.0.94].NGProd.dbo.[person] per
                LEFT JOIN ( SELECT  Nbr_new_pt ,
                                    nbr_pt_act_3m ,
                                    nbr_pt_act_6m ,
                                    nbr_pt_act_12m ,
                                    nbr_pt_act_18m ,
                                    nbr_pt_act_24m ,
                                    person_id
                            FROM    dwh.data_person_month
                            WHERE   rank_order = ( SELECT TOP 1
                                                            rank_order
                                                   FROM     dwh.data_person_month
                                                   WHERE    seq_date = CAST(SUBSTRING(CONVERT(CHAR(8), GETDATE(), 112),
                                                                                      1, 6) + '01' AS DATE)
                                                 )
                          ) sdp ON sdp.person_id = per.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.[patient] pat ON per.person_id = pat.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.mstr_lists ml ON ud.ud_demo3_id = ml.[mstr_list_item_id];


    END;
GO
