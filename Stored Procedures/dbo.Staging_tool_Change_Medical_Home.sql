SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Staging_tool_Change_Medical_Home]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



 DECLARE @origin_provider UNIQUEIDENTIFIER ,
    @from_medical_home_id UNIQUEIDENTIFIER,
	@from_medical_home_name VARCHAR(100),
	@to_medical_home_id UNIQUEIDENTIFIER,
	@to_medical_home_name VARCHAR(100),
	@switch int; 
    
 SET @origin_provider = '1AF10703-A2F5-4DCE-8033-1B960107115D';
 --  Thach
 SET @from_medical_home_id= 'D1521C2F-3A7A-41FA-B5FA-7BBB0715A9D0';
 SET @to_medical_home_id = 'EBAF047B-B263-4489-879C-034DB96DA74D'
 SET @from_medical_home_name = 'LifeLong Over 60 Health Center'
 SET @to_medical_home_name = 'LifeLong East Oakland'

 SET @switch =0
   
	
 CREATE TABLE #i2i_output
    (
      [med_rec_nbr] [VARCHAR](12)
    );
 INSERT INTO #i2i_output
        ( med_rec_nbr )
 VALUES ( '100561' ),
        ( '112066' ),
        ( '113792' ),
        ( '114382' ),
        ( '115945' ),
        ( '116268' ),
        ( '119132' ),
        ( '120981' ),
        ( '121958' ),
        ( '12380' ),
        ( '12448' ),
        ( '127628' ),
        ( '127630' ),
        ( '12782' ),
        ( '12857' ),
        ( '128633' ),
        ( '129655' ),
        ( '130627' ),
        ( '131083' ),
        ( '131545' ),
        ( '132433' ),
        ( '133849' ),
        ( '134366' ),
        ( '140197' ),
        ( '141413' ),
        ( '144502' ),
        ( '145766' ),
        ( '146942' ),
        ( '15090' ),
        ( '15116' ),
        ( '15261' ),
        ( '15463' ),
        ( '15628' ),
        ( '15829' ),
        ( '167934' ),
        ( '19243' ),
        ( '21853' ),
        ( '30302' ),
        ( '30308' ),
        ( '30318' ),
        ( '30336' ),
        ( '30419' ),
        ( '30426' ),
        ( '30511' ),
        ( '31854' ),
        ( '35455' ),
        ( '60289' ),
        ( '60374' ),
        ( '60462' ),
        ( '61316' ),
        ( '94189' ),
        ( '94674' ),
        ( '67084' ),
        ( '67445' ),
        ( '70782' ),
        ( '70991' ),
        ( '71444' ),
        ( '72859' ),
        ( '74778' ),
        ( '82518' ),
        ( '86087' ),
        ( '8736' ),
        ( '88699' ),
        ( '93221' ),
        ( '99491' ),
        ( '98302' ),
        ( '98712' ),
        ( '98713' ),
        ( '140634' );


 SELECT pat.person_id
 INTO   #i2i_final_1
 FROM   #i2i_output i2i
        LEFT JOIN [10.183.0.94].NGProd.dbo.patient pat ON RIGHT('00000000000' + RTRIM(pat.med_rec_nbr), 12) = RIGHT('00000000000'
                                                                                                        + RTRIM(i2i.med_rec_nbr),
                                                                                                        12)
        LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON per.person_id = pat.person_id;



 SELECT ms.*
 INTO   #patient_change
 FROM   #i2i_final_1 ms
        INNER JOIN [10.183.0.94].NGProd.dbo.person per ON ms.person_id = per.person_id
        INNER JOIN [10.183.0.94].NGProd.dbo.provider_mstr prov ON per.primarycare_prov_id = prov.provider_id
        INNER JOIN [10.183.0.94].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                                                              AND per.primarycare_prov_id = @origin_provider
                                                              AND per.expired_ind != 'Y'
                                                              AND ud.ud_demo3_id = @from_medical_home_id;  
     DECLARE @enterprise_id VARCHAR(10) ,
                    @practice_id VARCHAR(10) ,
                    @user_id VARCHAR(10);
                SET @enterprise_id = '00001';
                SET @practice_id = '0001';
                SET @user_id = '0';
	

    
IF @switch =1 

BEGIN


-- Now get info into sig_events to make it auditable
           

                UPDATE  [10.183.0.94].NGProd.dbo.person_ud
                SET     per.ud_demo3_id = @to_medical_home_id,
				        per.modified_by = @user_id ,
                        per.modify_timestamp = GETDATE()
                FROM    [10.183.0.94].NGProd.dbo.person_ud per
                        INNER JOIN #patient_change pc ON pc.person_id = per.person_id;


                PRINT 'Update medical home for list of patients';

	-- Insert changes into sig_events table
       
		
                INSERT  INTO [10.183.0.94].NGProd.dbo.sig_events
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
                                27 AS sig_id ,
                                'Medical Home  from: '+@from_medical_home_name+'to: '+@to_medical_home_name AS sig_msg ,
                                @from_medical_home_name AS pre_mod ,
                                @to_medical_home_name AS post_mod ,
                                GETDATE() AS create_timestamp ,
                                @user_id AS created_by ,
                                GETDATE() AS modify_timestamp ,
                                @user_id AS modified_by ,
                                0 AS create_timestamp_tz ,
                                0 AS modify_timestamp_tz
                        FROM   #patient_change n; 	



                PRINT 'Added to Sig_events Table';
END


        SELECT  ms.*,
                per.primarycare_prov_id AS provider_id ,
                ud.ud_demo3_id AS medical_home_id ,
                ml.mstr_list_item_desc AS medical_home_name ,
                prov.description AS provider_name ,
                per.date_of_birth ,
                per.address_line_1 ,
                per.address_line_2 ,
                per.city ,
                per.state ,
                per.zip ,
                per.home_phone ,
                per.alt_phone
      
        FROM    #patient_change ms
                LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON ms.person_id = per.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.provider_mstr prov ON per.primarycare_prov_id = prov.provider_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.[person_ud] ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.[mstr_lists] ml ON ud.ud_demo3_id = ml.mstr_list_item_id
		

DROP TABLE #i2i_output
DROP TABLE #i2i_final_1 	
DROP TABLE #patient_change



END
GO
