SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_data_prov_user_loc]
AS
    BEGIN


        SET ANSI_NULLS ON;

        SET QUOTED_IDENTIFIER ON;


        IF OBJECT_ID('dwh.data_location') IS NOT NULL
            DROP TABLE dwh.data_location;
        IF OBJECT_ID('dwh.data_provider') IS NOT NULL
            DROP TABLE dwh.data_provider;
        IF OBJECT_ID('dwh.data_resource') IS NOT NULL
            DROP TABLE dwh.data_resource;
        IF OBJECT_ID('dwh.data_user') IS NOT NULL
            DROP TABLE dwh.data_user;
 

        SELECT  DISTINCT
                loc.location_id ,
                loc.location_name
        INTO    #temp_loc
        FROM    [10.183.0.94].NGProd.dbo.patient_encounter AS enc
                LEFT OUTER JOIN [10.183.0.94].NGProd.dbo.location_mstr AS loc ON enc.location_id = loc.location_id
        WHERE   ( loc.location_name <> '' )
                AND ( enc.practice_id = '0001' );
  

        SELECT  IDENTITY( INT, 1, 1 )  AS location_key,
		        loc.location_id ,
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


								



        SELECT  IDENTITY( INT, 1, 1 )  AS provider_key,
			    provider_id = prov.provider_id ,
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

        SELECT  IDENTITY( INT, 1, 1 )  AS resource_key,
		         resource_id ,
                resource_name = r.description
        INTO    [Staging_Ghost].dwh.[data_resource]
        FROM    [10.183.0.94].[NGProd].[dbo].[resources] r;



        SELECT  IDENTITY( INT, 1, 1 )  AS user_key,
		        [enterprise_id] ,
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









    END;
GO
