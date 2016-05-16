SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_data_person_dp_month]
AS
  BEGIN


	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	   IF OBJECT_ID('dwh.data_person_dp_month') IS NOT NULL
            DROP TABLE dwh.data_person_dp_month
	
     
	 --Ok First go to the enc and appt table and grab all the per_mon_id with nbr_billable_enc =1
	 --Then create a lagging variable for different counts
	 --Then save back to the table dp table.
	 --Then create new fact table with that data
	 
	 --Add counts of PCP changes (Probably should do that in NP)
	 --Add countts of Medical Home Changes

	 	
        DECLARE @build_dt_start VARCHAR(8)



        SET @build_dt_start = '20100301';

		
         SELECT distinct  per_mon_id ,
                                nbr_bill_enc
                       INTO #enc_app
					   FROM     [sqlprod1\ghost].Prod_Ghost.dwh.data_appointment
                       WHERE    nbr_bill_enc = 1
                     
            SELECT 
                    dp.* ,
					CASE
						WHEN dp.ng_data = 1 THEN MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) 
						ELSE  MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id_ecw ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW )
					END
						AS nbr_pt_act_3m ,
					CASE
						WHEN dp.ng_data = 1 THEN MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 5 PRECEDING AND CURRENT ROW ) 
						ELSE MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id_ecw ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 5 PRECEDING AND CURRENT ROW )
					END
						AS nbr_pt_act_6m ,
					CASE
						WHEN dp.ng_data = 1 THEN MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 11 PRECEDING AND CURRENT ROW ) 
						ELSE MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id_ecw ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 11 PRECEDING AND CURRENT ROW )
					END
						AS nbr_pt_act_12m ,
					CASE
						WHEN dp.ng_data = 1 THEN MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 17 PRECEDING AND CURRENT ROW ) 
						ELSE MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id_ecw ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 17 PRECEDING AND CURRENT ROW )
					END
						AS nbr_pt_act_18m ,
                    CASE
						WHEN dp.ng_data = 1 THEN MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 23 PRECEDING AND CURRENT ROW ) 
						ELSE MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id_ecw ORDER BY dp.first_mon_date ASC  ROWS BETWEEN 23 PRECEDING AND CURRENT ROW )
					END
						AS nbr_pt_act_24m ,
					--Currently no historical data for ECW pcp or mh
                    IIF(LAG(dp.mh_hx_key, 1) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC ) != dp.mh_hx_key, 1, 0) AS nbr_pt_mh_change ,
                    IIF(LAG(dp.pcp_hx_key, 1) OVER ( PARTITION BY dp.person_id ORDER BY dp.first_mon_date ASC ) != dp.pcp_hx_key, 1, 0) AS nbr_pt_pcp_change ,
					CASE
						WHEN dp.ng_data = 1 THEN IIF(MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id ) = 0, 1, 0)
						ELSE IIF(MAX(ISNULL(ea.nbr_bill_enc, 0)) OVER ( PARTITION BY dp.person_id_ecw ) = 0, 1, 0)
					END
						AS nbr_pt_never_active 
            
			INTO #temp1       
            FROM    dwh.data_person_nd_month dp
                    LEFT JOIN #enc_app ea ON ea.per_mon_id = dp.per_mon_id;  

--clean up zip data
UPDATE  dp
    
	set  zip = (SELECT TOP 1 ez.zipcode FROM etl.data_zipcode ez WHERE LEFT(dp.[zip],5) = LEFT(ez.zipcode,5) )


FROM  #temp1 dp


SELECT *, [address_line_1] +' ' +[address_line_2]+' '+[city]+' '+ [state]+' '+[zip] AS [Address Full],
                    CASE WHEN COALESCE(nbr_pt_act_3m,0)=0 THEN 1 ELSE 0 end AS nbr_pt_inact_3m ,
                    CASE WHEN COALESCE(nbr_pt_act_6m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_6m ,
                    CASE WHEN COALESCE(nbr_pt_act_12m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_12m ,
                    CASE WHEN COALESCE(nbr_pt_act_18m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_18m ,
                    CASE WHEN COALESCE(nbr_pt_act_24m,0)=0 THEN 1 ELSE 0 END AS nbr_pt_inact_24m 



 INTO dwh.data_person_dp_month FROM #temp1

   

	    ALTER TABLE Staging_Ghost.dwh.data_person_dp_month
        ADD CONSTRAINT per_mon_id_pk32 PRIMARY KEY (per_mon_id);

    END;
GO
