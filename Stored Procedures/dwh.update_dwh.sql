SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_dwh]
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


        IF OBJECT_ID('dwh.data_location') IS NOT NULL
            DROP TABLE dwh.data_location;
   /*     IF OBJECT_ID('dwh.data_provider') IS NOT NULL
            DROP TABLE dwh.data_provider;
        IF OBJECT_ID('dwh.data_resource') IS NOT NULL
            DROP TABLE dwh.data_resource;
        IF OBJECT_ID('dwh.data_user') IS NOT NULL
            DROP TABLE dwh.data_user;
        IF OBJECT_ID('dwh.data_person') IS NOT NULL
            DROP TABLE dwh.data_person;
        IF OBJECT_ID('dwh.data_person_month') IS NOT NULL
            DROP TABLE dwh.data_person_month;
        IF OBJECT_ID('tempdb..#patients_controlled_rx') IS NOT NULL
            DROP TABLE #patients_controlled_rx;
        IF OBJECT_ID('tempdb..#all_patients') IS NOT NULL
            DROP TABLE #all_patients;
        IF OBJECT_ID('tempdb..#patients_w_charges ') IS NOT NULL
            DROP TABLE #patients_w_charges; 
        IF OBJECT_ID('tempdb..#patients_w_appts') IS NOT NULL
            DROP TABLE #patients_w_appts;
        IF OBJECT_ID('tempdb..#patients_w_appts') IS NOT NULL
            DROP TABLE #patients_w_appts;
        IF OBJECT_ID('tempdb..#temp_loc') IS NOT NULL
            DROP TABLE #temp_loc;
			*/


        SELECT  DISTINCT
                loc.location_id ,
                loc.location_name
        INTO    #temp_loc
        FROM    [10.183.0.94].NGProd.dbo.patient_encounter AS enc
                LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.location_mstr AS loc ON enc.location_id = loc.location_id
        WHERE   ( loc.location_name <> '' )
                AND ( enc.practice_id = '0001' );
  

        SELECT  loc.location_id ,
                loc.location_name ,
                ud_demo3_id = CASE WHEN loc.location_id = 'CE01BF12-1DC0-4C09-9694-474C8EEA8327'
                                   THEN CAST('8125418E-7B63-4D4C-901B-63C0BFE95A53' AS UNIQUEIDENTIFIER)  --LifeLong Ashby Health Center
                                   WHEN loc.location_id = 'E4CDE909-10FB-4B3E-8AEE-27298138F4AF'
                                   THEN CAST('D3C9A792-EA26-4A26-9336-94399832CB79' AS UNIQUEIDENTIFIER) --LifeLong Berkeley Primary Care
                                   WHEN loc.location_id = 'B9202BC6-62BF-43CB-A63D-B0F94159B6A3'
                                   THEN CAST('962C60B9-D7E0-452A-BF17-4A6ED6023E36' AS UNIQUEIDENTIFIER)  --LifeLong Brookside Center
                                   WHEN loc.location_id = '6EBE563F-39A4-49C1-936A-B6966CECFF7C'
                                   THEN CAST('578B940F-EC70-4D1D-9DEB-A2A3AE671719' AS UNIQUEIDENTIFIER)  --LifeLong Dental Center
                                   WHEN loc.location_id = '9567D24D-2B4F-402B-A7CA-0546A85D8CF3'
                                   THEN CAST('453F0729-40D3-4CD8-BC8D-F30E3865A882' AS UNIQUEIDENTIFIER)  --LifeLong Downtown Oakland Clinic
                                   WHEN loc.location_id = '1A0FECF5-00C2-4E16-BFDA-D529166A3DC8'
                                   THEN CAST('EBAF047B-B263-4489-879C-034DB96DA74D' AS UNIQUEIDENTIFIER) --LifeLong East Oakland
                                   WHEN loc.location_id = '1A0FECF5-00C2-4E16-BFDA-D529166A3DC8'
                                   THEN CAST('76BD59E7-60AE-4160-B739-29BCEC6A7EA1' AS UNIQUEIDENTIFIER)  --LifeLong East Oakland ADHC
                                   WHEN loc.location_id = 'A6BCC717-C0C9-454A-90FC-1EF010256FE4'
                                   THEN CAST('DE5D740A-A20C-4D45-A38F-AF00F9E99653' AS UNIQUEIDENTIFIER)  --LifeLong Eastmont Center
                                   WHEN loc.location_id = 'E9C81D34-ECF1-4851-B3E3-6A01E28AEF84'
                                   THEN CAST('3E675DED-89FE-4FDA-A61B-2D02668FC98D' AS UNIQUEIDENTIFIER)  --LifeLong Elmhurst/Alliance Academy
                                   WHEN loc.location_id = 'A8DFDE55-EEB0-4353-ACC5-AC39B792841D'
                                   THEN CAST('58FEA7B9-61C9-43CA-8A24-37BE9619727D' AS UNIQUEIDENTIFIER)  --LifeLong EO Wellness Center
                                   WHEN loc.location_id = '6678B8DA-C10E-442C-97DC-D40979D7C2DF'
                                   THEN CAST('C138486D-4C26-4D92-B553-E95400E197BF' AS UNIQUEIDENTIFIER)  --LifeLong Howard Daniel Clinic
                                   WHEN loc.location_id = 'C2678A20-C0B9-46C6-8E10-7E1ACCB6D826'
                                   THEN CAST('0E88F95B-4790-4DB4-AF36-D025593AAB07' AS UNIQUEIDENTIFIER)  --LifeLong Jenkins Pediatric Center
                                   WHEN loc.location_id = '8BAD2EFD-B455-43B7-AA73-687ACFFF789E'
                                   THEN CAST('D1521C2F-3A7A-41FA-B5FA-7BBB0715A9D0' AS UNIQUEIDENTIFIER)  --LifeLong Over 60 Health Center
                                   WHEN loc.location_id = '18ABDAF4-C538-4E07-9C02-07CAA576F49B'
                                   THEN CAST('621890E1-B2EC-4AFB-9752-6C77063D461B' AS UNIQUEIDENTIFIER)   --LifeLong Richmond Clinic
                                   WHEN loc.location_id = 'EAE9576F-6B6F-46F0-98AC-7D057B27E18B'
                                   THEN CAST('09C57FBA-16D2-4828-B884-E7B9BCBD8252' AS UNIQUEIDENTIFIER)   --LifeLong Rosa Parks School
                                   WHEN loc.location_id = '8BAD2EFD-B455-43B7-AA73-687ACFFF789E'
                                   THEN CAST('1DFC42E0-321F-43DD-8F33-34BB4C753BCE' AS UNIQUEIDENTIFIER)  --LifeLong SNF-Nursing Over 60
                                   WHEN loc.location_id = '0E6B0497-44E6-4C1C-AC3C-668999AA6B3F'
                                   THEN CAST('FC9346CE-EB14-4060-B548-472216347BA0' AS UNIQUEIDENTIFIER)  --LifeLong Supportive Housing Project
                                   WHEN loc.location_id = '4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD'
                                   THEN CAST('F6EC14C6-8ECF-4A0E-9663-FF79F88D3D51' AS UNIQUEIDENTIFIER)  --LifeLong Thunder Road
                                   WHEN loc.location_id = 'F62ED25A-6AC2-4355-A6E4-72B1326F39AF'
                                   THEN CAST('131B16DE-F576-4028-AC08-158470F42599' AS UNIQUEIDENTIFIER)  --LifeLong West Berkeley Family Practice
                                   WHEN loc.location_id = '5A972255-18DD-4F52-B4D2-F10C12C8F08F'
                                   THEN CAST('D305AD2A-FBA9-4F77-9D03-4DFDEE33662C' AS UNIQUEIDENTIFIER)    --LifeLong West Oakland Middle School
                              END ,
                healthpac_id = CASE WHEN loc.location_id = 'CE01BF12-1DC0-4C09-9694-474C8EEA8327'
                                    THEN CAST('4002' AS INT)  --LifeLong Ashby Health Center
	--	when loc.location_id =  'E4CDE909-10FB-4B3E-8AEE-27298138F4AF'   then  cast( 'D3C9A792-EA26-4A26-9336-94399832CB79' as uniqueidentifier) --LifeLong Berkeley Primary Care
	--	when loc.location_id =  'B9202BC6-62BF-43CB-A63D-B0F94159B6A3'   then  cast( '962C60B9-D7E0-452A-BF17-4A6ED6023E36' as uniqueidentifier)  --LifeLong Brookside Center
                                    WHEN loc.location_id = '6EBE563F-39A4-49C1-936A-B6966CECFF7C'
                                    THEN CAST('4008' AS INT)  --LifeLong Dental Center
                                    WHEN loc.location_id = '9567D24D-2B4F-402B-A7CA-0546A85D8CF3'
                                    THEN CAST('4004' AS INT)  --LifeLong Downtown Oakland Clinic
                                    WHEN loc.location_id = '1A0FECF5-00C2-4E16-BFDA-D529166A3DC8'
                                    THEN CAST('4012' AS INT) --LifeLong East Oakland
	--	when loc.location_id =  '1A0FECF5-00C2-4E16-BFDA-D529166A3DC8'   then  cast( '76BD59E7-60AE-4160-B739-29BCEC6A7EA1' as uniqueidentifier)  --LifeLong East Oakland ADHC
	--	when loc.location_id =  'A6BCC717-C0C9-454A-90FC-1EF010256FE4'   then  cast( 'DE5D740A-A20C-4D45-A38F-AF00F9E99653' as uniqueidentifier)  --LifeLong Eastmont Center
	--	when loc.location_id =  'E9C81D34-ECF1-4851-B3E3-6A01E28AEF84'   then  cast( '3E675DED-89FE-4FDA-A61B-2D02668FC98D' as uniqueidentifier)  --LifeLong Elmhurst/Alliance Academy
	--	when loc.location_id =  'A8DFDE55-EEB0-4353-ACC5-AC39B792841D'   then  cast( '58FEA7B9-61C9-43CA-8A24-37BE9619727D' as uniqueidentifier)  --LifeLong EO Wellness Center
                                    WHEN loc.location_id = '6678B8DA-C10E-442C-97DC-D40979D7C2DF'
                                    THEN CAST('4006' AS INT)  --LifeLong Howard Daniel Clinic
	--	when loc.location_id =  'C2678A20-C0B9-46C6-8E10-7E1ACCB6D826'   then  cast( '0E88F95B-4790-4DB4-AF36-D025593AAB07' as uniqueidentifier)  --LifeLong Jenkins Pediatric Center
                                    WHEN loc.location_id = '8BAD2EFD-B455-43B7-AA73-687ACFFF789E'
                                    THEN CAST('4010' AS INT)  --LifeLong Over 60 Health Center
                                    WHEN loc.location_id = '18ABDAF4-C538-4E07-9C02-07CAA576F49B'
                                    THEN CAST('4004' AS INT)   --LifeLong Richmond Clinic
	--	when loc.location_id =  'EAE9576F-6B6F-46F0-98AC-7D057B27E18B'   then  cast( '09C57FBA-16D2-4828-B884-E7B9BCBD8252' as uniqueidentifier)   --LifeLong Rosa Parks School
	--	when loc.location_id =  '8BAD2EFD-B455-43B7-AA73-687ACFFF789E'   then  cast( '1DFC42E0-321F-43DD-8F33-34BB4C753BCE' as uniqueidentifier)  --LifeLong SNF-Nursing Over 60
	--	when loc.location_id =  '0E6B0497-44E6-4C1C-AC3C-668999AA6B3F'   then  cast( 'FC9346CE-EB14-4060-B548-472216347BA0' as uniqueidentifier)  --LifeLong Supportive Housing Project
	--	when loc.location_id =  '4E4BCE9C-FDBD-4A96-BFF1-F001FC52E5DD'   then  cast( 'F6EC14C6-8ECF-4A0E-9663-FF79F88D3D51' as uniqueidentifier)  --LifeLong Thunder Road
                                    WHEN loc.location_id = 'F62ED25A-6AC2-4355-A6E4-72B1326F39AF'
                                    THEN CAST('4014' AS INT)  --LifeLong West Berkeley Family Practice
	--	when loc.location_id =  '5A972255-18DD-4F52-B4D2-F10C12C8F08F'   then  cast( 'D305AD2A-FBA9-4F77-9D03-4DFDEE33662C' as uniqueidentifier)    --LifeLong West Oakland Middle School
                               END
        INTO    dwh.data_location
        FROM    #temp_loc loc;


								
/*


        SELECT  provider_id = prov.provider_id ,
                provider_name = prov.description ,
                prov.ssn ,
                prov.primary_loc_id ,
                COALESCE(prov.degree, '') AS degree ,
                prov.first_name ,
                prov.last_name ,
                prov.middle_name ,
                prov.city ,
                prov.state ,
                prov.zip
        INTO    [Staging_Ghost].dwh.[data_provider]
        FROM    [10.183.0.94].[NGProd].[dbo].[provider_mstr] prov;

        SELECT  resource_id ,
                resource_name = r.description
        INTO    [Staging_Ghost].dwh.[data_resource]
        FROM    [10.183.0.94].[NGProd].[dbo].[resources] r;



        SELECT  [enterprise_id] ,
                [practice_id] ,
                [user_id] ,
                provider_id ,
                [last_name] ,
                [first_name] ,
                [mi] ,
                [start_date] ,
                [email_login_id] ,
                [login_id] ,
                [last_logon_date] ,
                [delete_ind] ,
                [created_by] ,
                [create_timestamp] ,
                [credentialed_staff_ind] ,
                CONCAT(first_name, ' ', last_name) AS FullName
        INTO    [dwh].[data_user]
        FROM    [10.183.0.94].[NGProd].[dbo].[user_mstr];







	---Get all persons
---Add patients with Charges -- If appointment or charges only set flag
---Add patients with appointments





        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);

        SET @build_dt_start = CONVERT(VARCHAR(8), GETDATE(), 112); --This routine will build current and hx data from begin to end date 
        SET @build_dt_end = CONVERT(VARCHAR(8), GETDATE(), 112);

        SET @build_dt_start = '20100101';

		

        SELECT  per.[person_id] AS person_id ,
                [primarycare_prov_id] AS pcp_id_cur_mon ,
                IDENTITY( INT, 1, 1 )  AS per_mon_id ,
                CAST(tim.seq_date + '01' AS DATE) AS seq_date ,
                CASE 
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date (not dead yet) and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE) THEN NULL
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y'
                               THEN CASE WHEN ISNULL([date_of_birth], '') != ''
                                         THEN DATEDIFF(YY, CAST([date_of_birth] AS DATE),
                                                       CAST(tim.seq_date + '01' AS DATE))
                                         ELSE NULL
                                    END
                               ELSE NULL
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE) THEN NULL
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y'
                               THEN CASE WHEN ISNULL([date_of_birth], '') != ''
                                         THEN DATEDIFF(YY, CAST([date_of_birth] AS DATE),
                                                       CAST(tim.seq_date + '01' AS DATE))
                                         ELSE NULL
                                    END
                               ELSE NULL
                          END
                END AS CurMon_Pt_Age ,
                CASE 
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE)
                               THEN DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE),
                                             CAST(tim.seq_date + '01' AS DATE)) 
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN NULL
                               ELSE DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE),
                                             CAST(tim.seq_date + '01' AS DATE))
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE)
                               THEN DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), CAST(tim.seq_date + '01' AS DATE)) 
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN NULL
                               ELSE DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), CAST(tim.seq_date + '01' AS DATE))
                          END
                END AS MemberMonths ,
                CASE  
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE)
                               THEN IIF(DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE),
                                                 CAST(tim.seq_date + '01' AS DATE)) <= 1, 1, 0)-- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 0
                               ELSE IIF(DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE),
                                                 CAST(tim.seq_date + '01' AS DATE)) <= 1, 1, 0)
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE)
                               THEN IIF(DATEDIFF(m, CAST(per.[create_timestamp] AS DATE),
                                                 CAST(tim.seq_date + '01' AS DATE)) <= 1, 1, 0)-- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 0
                               ELSE IIF(DATEDIFF(m, CAST(per.[create_timestamp] AS DATE),
                                                 CAST(tim.seq_date + '01' AS DATE)) <= 1, 1, 0)
                          END
                END AS Nbr_new_pt ,
                CASE  
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN 
		            --deal with expired patients 
                          IIF(DATEDIFF(m, CAST(pat.[first_office_enc_date] AS DATE), CAST(tim.seq_date + '01' AS DATE)) > 0, 1, 0)--This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN IIF(DATEDIFF(m, CAST(per.[create_timestamp] AS DATE), CAST(tim.seq_date + '01' AS DATE)) > 0, 1, 0)
                     ELSE 0
                END AS Nbr_pt_ever_enrolled ,
                CASE 
	          --This means when the first office visit is populated and is greater than the current date
                     WHEN ISNULL(pat.[first_office_enc_date], '') != ''
                          AND CAST(pat.[first_office_enc_date] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN 
		            --deal with expired patients 
                          CASE
					          --when the patient is noted to have expired after the current date (not dead yet) and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE) THEN 0
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 1
                               ELSE 0
                          END
			   --This now looks at using the creation date as substitue for First_office_date
                     WHEN ISNULL(pat.[first_office_enc_date], '') = ''
                          AND CAST(per.[create_timestamp] AS DATE) <= CAST(tim.seq_date + '01' AS DATE)
                     THEN CASE
					          --when the patient is noted to have expired after the current date and expired_date is populated
                               WHEN per.[expired_ind] = 'Y'
                                    AND ISNULL(per.[expired_date], '') != ''
                                    AND CAST(per.[expired_date] AS DATE) > CAST(tim.seq_date + '01' AS DATE) THEN 0
				              -- when the patient is noted to have expired before the current date or the expired date is not populated.
                               WHEN per.[expired_ind] = 'Y' THEN 1
                               ELSE 0
                          END
                END AS nbr_pt_deceased ,
                CASE WHEN SUBSTRING(per.[expired_date], 1, 6) = tim.seq_date THEN 1
                     ELSE 0
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
        INTO    #all_patients
        FROM    [10.183.0.94].NGProd.dbo.[person] per
                LEFT JOIN [10.183.0.94].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.[patient] pat ON per.person_id = pat.person_id
                CROSS JOIN ( SELECT DISTINCT
                                    CONVERT(CHAR(6), [PK_Date], 112) AS seq_date
                             FROM   [Staging_Ghost].[dbo].[staging_ng_Time_dim]
                             WHERE  PK_Date >= CAST(@build_dt_start AS DATETIME)
                                    AND PK_Date <= CAST(@build_dt_end AS DATETIME)
                           ) tim;




        SELECT  ISNULL(app_person_id, enc_person_id) AS person_id ,
                CAST(SUBSTRING(appt_date, 1, 6) + '01' AS DATE) AS Seq_date ,
                MAX([appt_loc_id]) AS Last_location ,
                SUM([nbr_no_show]) AS [nbr_no_show] ,
                SUM([nbr_cancelled]) AS [nbr_cancelled] ,
                SUM([nbr_deleted]) AS [nbr_deleted] ,
                SUM([nbr_rescheduled]) AS [nbr_rescheduled] ,
                SUM([nbr_bill_w_appt]) AS [nbr_bill_w_appt] ,
                SUM([nbr_non_bill_w_appt]) AS [nbr_non_bill_w_appt] ,
                SUM([Nbr_PCP_Appt]) AS [nbr_PCP_Appt] ,
                SUM([Nbr_NonPCP_Appt]) AS [nbr_NonPCP_Appt] ,
                SUM([nbr_kept_and_linked_enc]) AS [nbr_kept_and_linked_enc] ,
                SUM([nbr_kept_not_linked_enc]) AS [nbr_kept_not_linked_enc] ,
                AVG([Cycle_Min_slottime_to_Kept]) AS [avg_cycle_min_slottime_to_Kept] ,
                AVG([Cycle_Min_Kept_CheckedOut]) AS [avg_cycle_min_Kept_CheckedOut] ,
                SUM(IIF([Ct_Controlled] > 0
                    AND [nbr_kept_and_linked_enc] > 0, 1, 0)) AS nbr_controlled_rx_visits ,
                SUM(IIF(ISNULL([Ct_Controlled], 0) < 1
                    AND [nbr_kept_and_linked_enc] > 0, 1, 0)) AS nbr_noncontrolled_rx_visits
        INTO    #patients_w_appts
        FROM    [Staging_Ghost].[dbo].[staging_ng_appointment_data_] ap
                LEFT JOIN ( SELECT DISTINCT
                                    [person_id] ,
                                    [provider_id] ,
                                    enc_id ,
                                    [rx_id] ,
                                    [drug_dea_class] ,
                                    start_date ,
                                    seq_date = CAST(SUBSTRING(CONVERT(CHAR(8), start_date, 112), 1, 6) + '01' AS DATE) ,
                                    Ct_Controlled = 1
                            FROM    [Staging_Ghost].[dbo].[staging_ng_pharmacy_data_]
                            WHERE   drug_dea_class >= 2
                                    AND ( start_date >= @build_dt_start
                                          AND start_date <= @build_dt_end
                                        )
                          ) c ON ISNULL(ap.app_person_id, ap.enc_person_id) = c.person_id
                                 AND ap.enc_uid = c.enc_id
        WHERE   ISNULL(ap.app_person_id, ap.enc_person_id) IS NOT NULL
                AND ap.appt_date IS NOT NULL
                AND ( ap.appt_date >= @build_dt_start
                      AND ap.appt_date <= @build_dt_end
                    )
        GROUP BY ISNULL(ap.app_person_id, ap.enc_person_id) ,
                SUBSTRING(appt_date, 1, 6)
        ORDER BY ISNULL(ap.app_person_id, ap.enc_person_id) ,
                SUBSTRING(appt_date, 1, 6);




        DECLARE @mvc TABLE
            (
              sim_code VARCHAR(12) PRIMARY KEY
            );
	
        INSERT  INTO @mvc
                ( sim_code
                )
                SELECT DISTINCT
                        sxm.service_item_id
                FROM    [10.183.0.94].NGProd.dbo.svc_category_mstr scm
                        INNER JOIN [10.183.0.94].NGProd.dbo.svc_xref_mstr sxm ON scm.svc_category_id = sxm.svc_category_id; --where scm.short_description = @svc_category



        SELECT  enc.person_id AS person_id ,
                CAST(SUBSTRING(CONVERT(CHAR(8), enc.billable_timestamp, 112), 1, 6) + '01' AS DATE) AS Seq_date ,
                COUNT(enc.enc_id) AS Charge_Enc_Ct
        INTO    #patients_w_charges
        FROM    [10.183.0.94].NGProd.dbo.patient_encounter enc
                INNER JOIN [10.183.0.94].NGProd.dbo.charges chg ON enc.enc_id = chg.source_id
                INNER JOIN @mvc mvc ON chg.service_item_id = mvc.sim_code
        WHERE   chg.link_id IS NULL
                AND enc.billable_timestamp >= CAST(@build_dt_start AS DATETIME)
                AND enc.billable_timestamp <= CAST(@build_dt_end AS DATETIME)
        GROUP BY enc.person_id ,
                CAST(SUBSTRING(CONVERT(CHAR(8), enc.billable_timestamp, 112), 1, 6) + '01' AS DATE);



        SELECT  person_id ,
                seq_date ,
                SUM(Ct_Controlled) AS ct_controlled
        INTO    #patients_controlled_rx
        FROM    ( SELECT DISTINCT
                            [person_id] ,
                            [provider_id] ,
                            [rx_id] ,
                            [drug_dea_class] ,
                            start_date ,
                            seq_date = CAST(SUBSTRING(CONVERT(CHAR(8), start_date, 112), 1, 6) + '01' AS DATE) ,
                            Ct_Controlled = 1
                  FROM      [Staging_Ghost].[dbo].[staging_ng_pharmacy_data_]
                  WHERE     drug_dea_class >= 2
                            AND ( start_date >= @build_dt_start
                                  AND start_date <= @build_dt_end
                                )
                ) c
        GROUP BY person_id ,
                seq_date;

 
        SELECT  ap.* ,
                nbr_controlled_rx_visits AS nbr_ap_controlled_rx ,
                nbr_noncontrolled_rx_visits AS nbr_ap_no_controlled_rx ,
                [nbr_no_show] AS nbr_ap_no_show ,
                [nbr_cancelled] AS nbr_ap_cancelled ,
                [nbr_deleted] AS nbr_ap_deleted ,
                [nbr_rescheduled] AS nbr_ap_rescheduled ,
                [nbr_bill_w_appt] AS nbr_ap_bill_w_appt ,
                [nbr_non_bill_w_appt] AS nbr_ap_non_bill_w_appt ,
                [nbr_PCP_Appt] AS nbr_ap_pcp_appt ,
                [nbr_NonPCP_Appt] AS nbr_ap_nonpcp_Appt ,
                [nbr_kept_and_linked_enc] AS nbr_ap_kept_and_linked_enc ,
                [nbr_kept_not_linked_enc] AS nbr_ap_kept_not_linked_enc ,
                CASE WHEN ( Charge_Enc_Ct IS NOT NULL
                            AND nbr_kept_and_linked_enc IS NOT NULL
                            AND Charge_Enc_Ct > nbr_kept_and_linked_enc
                          ) THEN Charge_Enc_Ct - nbr_kept_and_linked_enc
                     ELSE NULL
                END AS [nbr_enc_w_charges_not_linked_appt] ,
                Charge_Enc_Ct AS nbr_enc_w_charges ,
                [avg_cycle_min_slottime_to_Kept] AS ap_avg_cycle_min_slottime_to_kept ,
                [avg_cycle_min_Kept_CheckedOut] AS ap_avg_cycle_min_kept_checkedout ,
                IIF(( ISNULL(ct_controlled, 0)
                      + ISNULL(LAG(ct_controlled, 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0)
                      + ISNULL(LAG(ct_controlled, 12) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ), 0) ) > 0, 1, 0) AS nbr_chronic_pain_12m ,
                IIF(( ISNULL([nbr_kept_and_linked_enc], 0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0) ) > 0, 1, 0) AS nbr_pt_act_3m ,
                IIF(( ISNULL([nbr_kept_and_linked_enc], 0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0) ) > 0, 1, 0) AS nbr_pt_act_6m ,
                IIF(( ISNULL([nbr_kept_and_linked_enc], 0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 12) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0) ) > 0, 1, 0) AS nbr_pt_act_12m ,
                IIF(( ISNULL([nbr_kept_and_linked_enc], 0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 12) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 13) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 14) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 15) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 16) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 17) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 18) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0) ) > 0, 1, 0) AS nbr_pt_act_18m ,
                IIF(( ISNULL([nbr_kept_and_linked_enc], 0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 1) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 2) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 3) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 4) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 5) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 6) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 7) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 8) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 9) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 10) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 11) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 12) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 13) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 14) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 15) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 16) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 17) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 18) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 19) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 20) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 21) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 22) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 23) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0)
                      + ISNULL(LAG([nbr_kept_and_linked_enc], 24) OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC ),
                               0) ) > 0, 1, 0) AS nbr_pt_act_24m ,
                rank_order = ROW_NUMBER() OVER ( PARTITION BY ap.person_id ORDER BY ap.seq_date ASC )
        INTO    dwh.data_person_month
        FROM    #all_patients ap
                LEFT JOIN #patients_w_appts aa ON aa.person_id = ap.person_id
                                                  AND aa.Seq_date = ap.seq_date
                LEFT JOIN #patients_w_charges ac ON ap.person_id = ac.person_id
                                                    AND ac.Seq_date = ap.seq_date
                LEFT JOIN #patients_controlled_rx ar ON ap.person_id = ar.person_id
                                                        AND ar.seq_date = ap.seq_date;


	 

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

				*/
    END;
GO
