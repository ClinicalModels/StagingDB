SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Mansalis
-- Create date: 8/2015
-- Description:	This procedure generates a normalized panels for PCP by distributing a set of
--              patient that are from a set of providers leaving or patients with no PCP assigned
--              based on FTE and exisiting panel size.  Distribution is based on language requirements
--              of the patient and most freq visit with receiving provider
-- Dependency:  #i2i_output and setting the FTE of provider_id of providers receiving patients. 
-- Future:
-- Clean up code a document and remove temp tables and unnecessary steps.

-- =============================================
CREATE PROCEDURE [dbo].[Staging_tool_Reassign_PCP_v1]
AS
    BEGIN



        DECLARE @tot_pcp_fte DECIMAL(5, 2) ,
            @norm_pat_FTE1 INT ,
            @norm_pat_FTE2 INT ,
            @tot_pat_giving INT ,
            @tot_pat_unassigned INT ,
            @tot_pat_receiving1 INT ,
            @tot_pat_receiving2 INT ,
            @tot_pat_pcp INT ,
            @over_pat DECIMAL(5, 2) ,
            @tot_pcp_fte2 DECIMAL(5, 2) ,
            @final_patients INT ,
            @final_sol_providers INT ,
            @reduce INT ,
            @Medical_home UNIQUEIDENTIFIER ,
            @Dummy UNIQUEIDENTIFIER ,
            @switch INT;

        SET @switch = 1; -- should we reassign patients ?



        SET @Medical_home = 'D1521C2F-3A7A-41FA-B5FA-7BBB0715A9D0'; -- What site are you currently working on?
        SET @Dummy = '7746F1A2-576A-42E9-6D91-6371AF7D5A25'; -- This is for using if you have a provider you want to accound for that has not arrived yet.




   
        CREATE TABLE #Provider_Pool
            (
              provider_id UNIQUEIDENTIFIER ,
              data_control DECIMAL(5, 2) ,
              lang VARCHAR(100) ,
              sol_ind NCHAR(1) ,
              reduce INT
            );

   
	
			--sol_ind  - R getting patient, G Giving patients, E -exclude from solution
			-- last number is reduce panel amount and leave unassigned.
			--data_control - pcp_shifts as a fraction of a week 0.1 is one shift
			 
        INSERT  INTO #Provider_Pool
                ( provider_id, data_control, lang, sol_ind, reduce )
        VALUES  ( '0E16E96C-4320-4379-AC6F-011D90984197', 0.30, 'Spanish', 'R', 0 ), --Searls
                ( 'AABE6BEC-2F02-4514-A146-07BF716CA8C3', 0.50, 'Chinese, Cantonese, Mandarin', 'R', 0 ), --Chen
                ( '1BAC4E4E-7C06-417E-92BA-FE6BDD0EFFF0', 0.90, 'Spanish', 'R', 200 ), --Elton
                ( 'A8E7C0C1-C631-4DF2-AD2F-D3E7D67C729B', 0.60, 'French', 'R', 0 ), --ONeil
                ( '6DCFBE83-D216-40F1-AB52-8E73A04C5783', 0.40, '', 'R', 0 ), --Mansalis
                ( 'AF5FD141-084A-457D-8A08-36BB94DB1917', 0.70, '', 'G', 0 ), --Furer
                ( '1AF10703-A2F5-4DCE-8033-1B960107115D', 0.70, '', 'G', 0 ), --Thach
                ( 'D0AD0360-204F-43D9-886C-71FBC8FF6D1D', 0.90, 'Spanish', 'E', 0 ), --Meadows
                ( '269EFD50-7079-47F5-8AF3-4B2F5777409D', 0.30, '', 'E', 0 ), --Perisinotto
                ( '7746F1A5-576A-42E9-8D91-6371AF785A25', 0.30, 'Spanish, Italian', 'R', 0 ), -- bernstein
                ( 'FE225410-4D0C-48EC-BEF2-2F1D2FF0B546', 0.20, '', 'E', 0 ), --Zelma, Lewis
                ( '0AE37A15-564F-4FA0-BBFC-2C1D01F4374F', 0.60, '', 'R', 100 );  -- Oveson;

		

-- Get counts of patients for exisiting providers who have patients out there that are a part of over sixty
        SELECT  pp.provider_id ,
                prov.last_name ,
                pp.data_control ,
                pp.lang ,
                pp.sol_ind ,
                pp.reduce ,
                COUNT(per.person_id) AS patient_count
        INTO    #Provider_Pool_temp1
        FROM    #Provider_Pool pp
                LEFT JOIN ( SELECT  per.person_id ,
                                    per.primarycare_prov_id ,
                                    ud.ud_demo3_id ,
                                    COUNT(*) AS QTY
                            FROM    [10.183.0.64].NGProd.dbo.patient_encounter enc
                                    LEFT JOIN [10.183.0.64].NGProd.dbo.person per ON per.person_id = enc.person_id
                                    LEFT JOIN [10.183.0.64].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                            WHERE   enc.billable_ind = 'Y'
                                    AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 18
                                    AND per.expired_ind != 'Y'
                                    AND ud.ud_demo3_id = @Medical_home --Specific to Over60 for now
                            GROUP BY per.person_id ,
                                    per.primarycare_prov_id ,
                                    ud.ud_demo3_id
                          ) per ON pp.provider_id = per.primarycare_prov_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.provider_mstr prov ON pp.provider_id = prov.provider_id
        WHERE   (per.QTY >= 0 OR per.QTY IS NULL)
                OR pp.provider_id = @Dummy-- Include dummy provider here
GROUP BY        pp.provider_id ,
                prov.last_name ,
                pp.data_control ,
                pp.lang ,
                pp.sol_ind ,
                pp.reduce
        ORDER BY pp.data_control;



-- Total the number of FTE available for visits -- load to variable

        SELECT  @tot_pcp_fte = SUM(data_control)
        FROM    #Provider_Pool_temp1
        WHERE   sol_ind IN ( 'R' );

        SELECT  @tot_pat_pcp = SUM(patient_count)
        FROM    #Provider_Pool_temp1
        WHERE   sol_ind IN ( 'G', 'R' );

        SELECT  @tot_pat_giving = SUM(patient_count)
        FROM    #Provider_Pool_temp1
        WHERE   sol_ind IN ( 'G' );

        SELECT  @tot_pat_receiving1 = SUM(patient_count)
        FROM    #Provider_Pool_temp1
        WHERE   sol_ind IN ( 'R' );


-- Get total of all patients that are assigned to Over60 
--Eliminate deceased patients
-- Only active patient 18 month
-- There may be a subset of patients out there that have medical home at one site and provider at another (makes sense if provider has two different sites,
-- or could be a data integrity issue


--Add some code here that will add patient with medical home of over sixty but with a provider not in the E or R list
        SELECT  per.person_id ,
                per.primarycare_prov_id ,
                COUNT(*) AS QTY
        INTO    #unassigned_patients
        FROM    [10.183.0.64].NGProd.dbo.patient_encounter enc
                LEFT JOIN [10.183.0.64].NGProd.dbo.person per ON per.person_id = enc.person_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
        WHERE   enc.billable_ind = 'Y'
                AND per.expired_ind != 'Y'
                AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 18
                AND ( ( per.primarycare_prov_id NOT IN ( SELECT provider_id
                                                         FROM   #Provider_Pool
                                                         WHERE  sol_ind IN ( 'R', 'G', 'E' ) ) )
                      OR per.primarycare_prov_id IS NULL
                    )
                AND ud.ud_demo3_id = @Medical_home --Specific to Over60 for now
GROUP BY        per.person_id ,
                per.primarycare_prov_id;

        SELECT  @tot_pat_unassigned = COUNT(*)
        FROM    #unassigned_patients;


        SET @norm_pat_FTE1 = ( @tot_pat_giving + @tot_pat_unassigned + @tot_pat_receiving1 ) / @tot_pcp_fte;
        PRINT 'Total patient that come from giving providers: ' + CAST(@tot_pat_giving AS VARCHAR(10));
        PRINT 'Total unassigned patients at site: ' + CAST(@tot_pat_unassigned AS VARCHAR(10));
        PRINT 'Total FTE of receiving providers: ' + CAST(@tot_pcp_fte AS VARCHAR(10));
        PRINT 'Normalized patient panel for a 1.0 FTE provider - 1st pass: ' + CAST(@norm_pat_FTE1 AS VARCHAR(10));

--first pass solution has patients being subtracted from existing panels, this is not ideal 
        SELECT  * ,
                data_control * @norm_pat_FTE1 AS final_panel ,
                data_control * @norm_pat_FTE1 - patient_count AS Adjust_panel
        INTO    #Provider_Pool_temp2
        FROM    #Provider_Pool_temp1
        WHERE   sol_ind = 'R';

--second pass solution drops providers that are significantly over impanelled

        SELECT  @tot_pcp_fte2 = SUM(data_control)
        FROM    #Provider_Pool_temp2
        WHERE   Adjust_panel > 0;

        SELECT  @tot_pat_receiving2 = SUM(patient_count)
        FROM    #Provider_Pool_temp2
        WHERE   Adjust_panel > 0;


        SET @norm_pat_FTE2 = ( @tot_pat_giving + @tot_pat_unassigned + @tot_pat_receiving2 ) / @tot_pcp_fte2;

        PRINT 'Dropping providers that are over empanelled';
        PRINT 'Number of patient moving to receiving providers:'
            + CAST(( @tot_pat_giving + @tot_pat_unassigned ) AS VARCHAR(10));
        PRINT 'Number FTE for providers that are receiving patients:' + CAST(@tot_pcp_fte2 AS VARCHAR(10));
        PRINT 'Number of patients for normalized PCP when you remove folks that are over empanelled:'
            + CAST(@norm_pat_FTE2 AS VARCHAR(10));


        SELECT  * ,
                data_control * @norm_pat_FTE2 AS final_panel2 ,
                data_control * @norm_pat_FTE2 - patient_count AS Adjust_panel2
        INTO    #Provider_Pool_temp3
        FROM    #Provider_Pool_temp2
        WHERE   Adjust_panel > 0;



        SELECT  provider_id ,
                last_name ,
                data_control ,
                lang ,
                sol_ind ,
                patient_count ,
                patient_count / data_control AS inital_norm_panel ,
                ROUND(Adjust_panel2, 0) AS Add_Pat ,
                final_panel2 / data_control AS Final_norm_panel ,
                ROW_NUMBER() OVER ( ORDER BY ROUND(Adjust_panel2, 0) DESC ) AS Prov_row ,
                reduce
        INTO    #final_solution
        FROM    #Provider_Pool_temp3;

        SELECT  SUM(Add_Pat)
        FROM    #final_solution; 

        SELECT  *
        FROM    #final_solution;



--patient reassignment process
-- first based on language then who has seen the patient the most in the past 6 months
-- Random for everyone else

--create a patient that need to be changed table with language preference and provider with most visits in past 6 months otherwise null

--create a provider change table with the rows equal to the number spots and provider_id in proportion to patient that need to be added, random sort order
--merge provider change table to patient change table on language then provider using an inner join



--start with creating patient change table.


        SELECT  *
        INTO    #patient_change
        FROM    ( SELECT    per.person_id
                  FROM      #Provider_Pool pp
                            LEFT JOIN ( SELECT  per.person_id ,
                                                per.primarycare_prov_id ,
                                                ud.ud_demo3_id ,
                                                COUNT(*) AS QTY
                                        FROM    [10.183.0.64].NGProd.dbo.patient_encounter enc
                                                LEFT JOIN [10.183.0.64].NGProd.dbo.person per ON per.person_id = enc.person_id
                                                LEFT JOIN [10.183.0.64].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                                        WHERE   enc.billable_ind = 'Y'
                                                AND DATEDIFF(MONTH, enc.billable_timestamp, GETDATE()) <= 18
                                                AND per.expired_ind != 'Y'
                                                AND ud.ud_demo3_id = @Medical_home--Specific to Over60 for now
                                        GROUP BY per.person_id ,
                                                per.primarycare_prov_id ,
                                                ud.ud_demo3_id
                                      ) per ON pp.provider_id = per.primarycare_prov_id
                            LEFT JOIN [10.183.0.64].NGProd.dbo.provider_mstr prov ON pp.provider_id = prov.provider_id
                  WHERE     ( per.QTY > 0
                              OR pp.provider_id = @Dummy
                            ) -- Include dummy provider here
                            AND pp.sol_ind = 'G'
                  UNION
                  SELECT    person_id
                  FROM      #unassigned_patients
                ) AS tmp;





--Get rendering Provider if Rendering is >=3 in the past 18 months


        SELECT  pc.person_id ,
                enc.rendering_provider_id ,
                COUNT(*) AS QTY
        INTO    #prov_enc_pat1
        FROM    #patient_change pc
                LEFT JOIN ( SELECT  ec.person_id ,
                                    ec.rendering_provider_id
                            FROM    #final_solution fs
                                    INNER JOIN [10.183.0.64].NGProd.dbo.patient_encounter ec ON fs.provider_id = ec.rendering_provider_id
                            WHERE   ec.billable_ind = 'Y'
                                    AND DATEDIFF(MONTH, ec.billable_timestamp, GETDATE()) <= 18
                          ) enc ON enc.person_id = pc.person_id
        GROUP BY pc.person_id ,
                enc.rendering_provider_id;




        SELECT  person_id ,
                rendering_provider_id ,
                QTY ,
                ROW_NUMBER() OVER ( PARTITION BY person_id ORDER BY QTY DESC ) AS seq
        INTO    #prov_enc_pat2
        FROM    #prov_enc_pat1;

        SELECT  penc.person_id ,
                penc.rendering_provider_id ,
                COALESCE(REPLACE(per.language, '*', ''), 'English') AS language ,
                ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS ran_num
        INTO    #final_patient_list
        FROM    #prov_enc_pat2 penc
                INNER JOIN [10.183.0.64].NGProd.dbo.person per ON per.person_id = penc.person_id
        WHERE   seq = 1;




--Next Step is to create a table of the providers to match against this list.
--Also need to find a way to reduce total allocation and leave some patients without a PCP.




        SELECT  @final_patients = COUNT(*)
        FROM    #final_patient_list;




        SELECT  @final_sol_providers = COUNT(*)
        FROM    #final_solution;


--Result will be a final table with a a row with a for each patient that needs to be added 


--create a table and then start inserting rows as below

        CREATE TABLE #Provider_Slots
            (
              provider_id UNIQUEIDENTIFIER ,
              lang VARCHAR(100) ,
              ran_num INT
            );




        DECLARE @prv_loop INT ,
            @pat_loop INT ,
            @add_pat INT ,
            @provider_id UNIQUEIDENTIFIER ,
            @lang VARCHAR(100); 
       

        SELECT  @prv_loop = 1;


        WHILE @prv_loop <= @final_sol_providers
            BEGIN

                SELECT  @add_pat = Add_Pat ,
                        @provider_id = provider_id ,
                        @lang = lang ,
                        @reduce = reduce
                FROM    #final_solution
                WHERE   Prov_row = @prv_loop; 

                SELECT  @pat_loop = 1;

                WHILE @pat_loop <= ( @add_pat - @reduce )
                    BEGIN

                        INSERT  INTO #Provider_Slots
                        VALUES  ( @provider_id, @lang, ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) );
                        SELECT  @pat_loop = @pat_loop + 1;
                    END;
                SELECT  @prv_loop = @prv_loop + 1;
            END;




--Cycle through each patient and find a language and rendering provider match in the provider slot file.    
--When a match is found on language removed that record from the provider slot file and add to matched table
--If no match is found then moved to unmatched table
--How do you find a mtch?  Use a select statement first based on language --
-- if no match on language then select based on rendering provider_id

--if still no then umatched 
--When completed matching on language and rendering provider
--then run through unmatched randomized to remaining providers slots

-- create a match table and an unmatch table

   
        CREATE TABLE #Matched_patient
            (
              person_id UNIQUEIDENTIFIER ,
              provider_id UNIQUEIDENTIFIER ,
              lang VARCHAR(100) ,
              rendering_provider_id UNIQUEIDENTIFIER ,
              how_status VARCHAR(20)
            );


        CREATE TABLE #UnMatched_patient
            (
              person_id UNIQUEIDENTIFIER ,
              lang VARCHAR(100) ,
              rendering_provider_id UNIQUEIDENTIFIER
            );

        SELECT  *
        INTO    #new_provider_slots
        FROM    #Provider_Slots;



        DECLARE @patient_loop INT ,
            @cur_person_id UNIQUEIDENTIFIER ,
            @cur_language VARCHAR(100) ,
            @lang_count INT ,
            @row_num INT ,
            @Has_match INT ,
            @cur_rendering_id UNIQUEIDENTIFIER ,
            @match_ID UNIQUEIDENTIFIER; 



        SELECT  language ,
                COUNT(language) OVER ( PARTITION BY language ) AS lang_count ,
                person_id ,
                rendering_provider_id ,
                ran_num
        INTO    #cur_patient
        FROM    #final_patient_list;




        DECLARE Cur_patient CURSOR FAST_FORWARD
        FOR
            -- Create a cursor for processing the Languages
SELECT  language ,
        lang_count ,
        person_id ,
        rendering_provider_id
FROM    #cur_patient
ORDER BY lang_count ASC ,
        ran_num;

--Open the cursor
        OPEN Cur_patient;
--Save the values of the first row in variables
        FETCH NEXT FROM Cur_patient INTO @cur_language, @lang_count, @cur_person_id, @cur_rendering_id;
        WHILE @@FETCH_STATUS = 0
            BEGIN

         
				
--Find match based on language
                SELECT  @Has_match = 0;

                SELECT  @Has_match = COUNT(*)
                FROM    #new_provider_slots
                WHERE   lang LIKE '%' + RTRIM(LTRIM(@cur_language)) + '%';  --@cur_language; -- number of providers slots available with that language


--If match then

                PRINT @Has_match;

                IF @Has_match > 0
                    BEGIN
                        SELECT  @match_ID = NULL;

                        PRINT 'Language Match Found';
                        SELECT TOP 1
                                @match_ID = provider_id
                        FROM    #new_provider_slots
                        WHERE   lang LIKE '%' + RTRIM(LTRIM(@cur_language)) + '%';  

                        DELETE TOP ( 1 )
                        FROM    #new_provider_slots
                        WHERE   @match_ID = provider_id; 



                        INSERT  INTO #Matched_patient
                        VALUES  ( @cur_person_id, @match_ID, @cur_language, @cur_rendering_id, 'Language Match' );



                    END;

                ELSE
                    BEGIN
                        PRINT 'Language Match NOT  Found';
                        INSERT  INTO #UnMatched_patient
                                ( person_id ,
                                  lang ,
                                  rendering_provider_id
                                )
                        VALUES  ( @cur_person_id , -- person_id - uniqueidentifier
                                  @cur_language ,
                                  @cur_rendering_id
                                );




--Now look for rendering provider matches
                        SELECT  @Has_match = 0;

                        SELECT  @Has_match = COUNT(*)
                        FROM    #new_provider_slots
                        WHERE   provider_id = @cur_rendering_id;



--If match then

                        PRINT @Has_match;



                        IF @Has_match > 0
                            BEGIN
                                SELECT  @match_ID = NULL;
                                PRINT 'Rendering  Match Found';
                                SELECT TOP 1
                                        @match_ID = provider_id
                                FROM    #new_provider_slots
                                WHERE   provider_id = @cur_rendering_id;  

                                DELETE TOP ( 1 )
                                FROM    #new_provider_slots
                                WHERE   @match_ID = provider_id; 

--Delete from unmatched
                                DELETE TOP ( 1 )
                                FROM    #UnMatched_patient
                                WHERE   @cur_person_id = person_id; 


                                INSERT  INTO #Matched_patient
                                VALUES  ( @cur_person_id, @match_ID, @cur_language, @cur_rendering_id,
                                          'Frequent Provider' );

                            END;

                        ELSE
                            BEGIN
                                PRINT 'Rendering Match NOT  Found';
                            END;

                    END;         
  
  
  
   
                FETCH NEXT FROM Cur_patient INTO @cur_language, @lang_count, @cur_person_id, @cur_rendering_id;
	




            END;

        CLOSE Cur_patient;
        DEALLOCATE Cur_patient;


--Everybody is now matched or unmatched
--Now randomize remaining unmatched patients to remaining providers
 




 

        DECLARE unmatched_patient CURSOR FAST_FORWARD
        FOR
            -- Create a cursor for processing the Languages
SELECT  person_id
FROM    #UnMatched_patient
ORDER BY ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)); 

--Open the cursor
        OPEN unmatched_patient;
--Save the values of the first row in variables
        FETCH NEXT FROM unmatched_patient INTO @cur_person_id;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT  @match_ID = NULL;
                PRINT 'Assigning unmatched patients';

                SELECT TOP 1
                        @match_ID = provider_id
                FROM    #new_provider_slots;   

                DELETE TOP ( 1 )
                FROM    #new_provider_slots
                WHERE   @match_ID = provider_id; 

--Delete from unmatched
                DELETE TOP ( 1 )
                FROM    #UnMatched_patient
                WHERE   @cur_person_id = person_id; 


                INSERT  INTO #Matched_patient
                VALUES  ( @cur_person_id, @match_ID, NULL, NULL, 'Random Assignment' );



                FETCH NEXT FROM unmatched_patient INTO @cur_person_id;

            END;


   
	





        CLOSE unmatched_patient;
        DEALLOCATE unmatched_patient;

		

        SELECT  mp.person_id ,
                mp.provider_id ,
                per.first_name ,
                per.last_name ,
                pat.med_rec_nbr ,
                prov.description AS ProviderAssigned ,
                mp.how_status
        INTO    #matched_sub
        FROM    #Matched_patient mp
                LEFT JOIN [10.183.0.64].NGProd.dbo.patient pat ON mp.person_id = pat.person_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.person per ON per.person_id = pat.person_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.provider_mstr prov ON mp.provider_id = prov.provider_id;

				

        SELECT  ms.person_id ,
                ms.provider_id AS new_provider_id ,
                per.primarycare_prov_id AS old_provider_id ,
                ud.ud_demo3_id AS medical_home_id ,
                ml.mstr_list_item_desc AS medical_home_name ,
                prov.description AS old_provider_name ,
                ms.ProviderAssigned AS new_provider_name ,
                ms.first_name AS patient_fname ,
                ms.last_name AS patient_lname ,
                ms.how_status ,
                ms.med_rec_nbr ,
                per.date_of_birth ,
                per.address_line_1 ,
                per.address_line_2 ,
                per.city ,
                per.state ,
                per.zip ,
                per.home_phone ,
                per.alt_phone
        INTO    #matched_final
        FROM    #matched_sub ms
                LEFT JOIN [10.183.0.64].NGProd.dbo.person per ON ms.person_id = per.person_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.provider_mstr prov ON per.primarycare_prov_id = prov.provider_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.64].NGProd.dbo.[mstr_lists] ml ON ud.ud_demo3_id = ml.mstr_list_item_id
        WHERE   ms.provider_id IS NOT NULL;
              
                

        SELECT  *
        FROM    #matched_final;



        IF @switch = 1
            BEGIN
--Update person table with new primary care provider



-- Now get info into sig_events to make it auditable
                DECLARE @enterprise_id VARCHAR(10) ,
                    @practice_id VARCHAR(10) ,
                    @user_id VARCHAR(10);
                SET @enterprise_id = '00001';
                SET @practice_id = '0001';
                SET @user_id = '0';

                UPDATE  [10.183.0.64].NGProd.dbo.person
                SET     per.primarycare_prov_id = mf.new_provider_id ,
                        per.primarycare_prov_name = mf.new_provider_name ,
                        per.modified_by = @user_id ,
                        per.modify_timestamp = GETDATE()
                FROM    [10.183.0.64].NGProd.dbo.person per
                        INNER JOIN #matched_final mf ON mf.person_id = per.person_id;


                PRINT 'Patients have been moved to new provider.';

    -- Insert changes into sig_events table
       
        
                INSERT  INTO [10.183.0.64].NGProd.dbo.sig_events
                        ( sig_event_id ,
                          enterprise_id ,
                          practice_id ,
                          source1_id ,
                          event_source_type ,
                          sig_id ,
                          sig_msg ,
                          pre_mod ,
                          post_mod ,
                          create_timestamp ,
                          created_by ,
                          modify_timestamp ,
                          modified_by ,
                          create_timestamp_tz ,
                          modify_timestamp_tz
                        )
                        SELECT  NEWID() AS sig_event_id ,
                                @enterprise_id AS enterprise_id ,
                                @practice_id AS practice_id ,
                                n.person_id AS source1_id ,
                                4 AS event_source_type ,
                                25 AS sig_id ,
                                'Primary Care Provider Changed' AS sig_msg ,
                                n.old_provider_name AS pre_mod ,
                                n.new_provider_name AS post_mod ,
                                GETDATE() AS create_timestamp ,
                                @user_id AS created_by ,
                                GETDATE() AS modify_timestamp ,
                                @user_id AS modified_by ,
                                0 AS create_timestamp_tz ,
                                0 AS modify_timestamp_tz
                        FROM    #matched_final n;   








                PRINT 'Added to Sig_events Table';









            END;





-- Now actually update the records









        DROP TABLE #matched_sub;
        DROP TABLE #matched_final;

        DROP TABLE #cur_patient;

        DROP TABLE #new_provider_slots;
        DROP TABLE #Matched_patient;
        DROP TABLE #UnMatched_patient;

        DROP TABLE #Provider_Pool;
        DROP TABLE #Provider_Pool_temp1;
        DROP TABLE #Provider_Pool_temp2;
        DROP TABLE #Provider_Pool_temp3;
        DROP TABLE #final_solution;
        DROP TABLE #patient_change;
        DROP TABLE #final_patient_list; 
        DROP TABLE #Provider_Slots;
        DROP TABLE #prov_enc_pat1;
        DROP TABLE #prov_enc_pat2;
        DROP TABLE #unassigned_patients;




    END;
GO
