SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dwh].[update_data_person_day]
AS
    BEGIN

--Things to add 
-- make sure to add foreign and primary key constraints
--Get roll updates
--consider replacing NG keys with integer primary keys



        SET ANSI_NULLS ON;

        SET QUOTED_IDENTIFIER ON;


        IF OBJECT_ID('dwh.data_person_day') IS NOT NULL
            DROP TABLE dwh.data_person_day;
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



	---Get all persons
---Add patients with Charges -- If appointment or charges only set flag
---Add patients with appointments





        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);

        SET @build_dt_start = CONVERT(VARCHAR(8), GETDATE(), 112); --This routine will build current and hx data from begin to end date 
        SET @build_dt_end = CONVERT(VARCHAR(8), GETDATE(), 112);

        SET @build_dt_start = '20100301';



        SELECT  per.[person_id] AS person_id ,
                [primarycare_prov_id] AS pcp_id_cur,
                IDENTITY( INT, 1, 1 )  AS per_day_id ,
                CAST(tim.seq_date + '01' AS DATE) AS first_mon_date ,
                [date_of_birth] ,
				
			
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
                                    CONVERT(CHAR(8), [PK_Date], 112) AS seq_date
                             FROM   [Staging_Ghost].fds.dim_time
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
                CASE WHEN nbr_pt_deceased != 1
                          AND MemberMonths >= 1
						  AND ap.date_of_birth IS NOT NULL AND ap.seq_date IS NOT null
                     THEN DATEDIFF(YY, CAST(ap.[date_of_birth] AS DATE), CAST(ap.seq_date as DATE))
                     ELSE NULL
                END AS CurMon_Pt_Age ,
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
        INTO    dwh.data_person_day
        FROM    #all_patients ap
                LEFT JOIN #patients_w_appts aa ON aa.person_id = ap.person_id
                                                  AND aa.Seq_date = ap.seq_date
                LEFT JOIN #patients_w_charges ac ON ap.person_id = ac.person_id
                                                    AND ac.Seq_date = ap.seq_date
                LEFT JOIN #patients_controlled_rx ar ON ap.person_id = ar.person_id
                                                        AND ar.seq_date = ap.seq_date;


    END;
GO
