SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [prj].[finance_1510_O60_Time_audit_v1] as

Begin

WITH    Testdata
          AS ( SELECT   du.FullName ,
                        de.enc_nbr ,
                        1 AS grp ,
                        da.enc_id ,
                        enc_date ,
                        CASE WHEN da.cycle_min_readyforprovider_checkout > 180 THEN NULL
                             WHEN da.cycle_min_readyforprovider_checkout <= 3 THEN NULL
                             ELSE da.cycle_min_readyforprovider_checkout
                        END AS VALUE ,
                        CASE WHEN da.cycle_min_readyforprovider_checkout > 180 THEN NULL
                             WHEN da.cycle_min_readyforprovider_checkout <= 3 THEN NULL
                             ELSE da.cycle_min_kept_checkedout
                        END AS [Appointment Cycle Time]
               FROM     dwh.data_appointment da
                        INNER JOIN dwh.data_user du ON da.enc_rendering_key = du.user_key
                        INNER JOIN dwh.data_encounter de ON de.enc_key = da.enc_key
               WHERE    du.user_id IN ( 321, 323, 791, 320, 1049, 600, 1296, 1334, 1401, 313, 316 )
                        AND da.nbr_appt_kept_and_linked_enc = 1
                        AND da.enc_date >= CAST('20150601' AS DATE)
                        AND da.enc_date < CAST('20151001' AS DATE)

--ORDER BY du.FullName, enc_date
             ),



	  

	  

	  -- Ultimate goal #1 as calculated by SQL 2012 (PERCENTILE_CONT)
        a AS ( SELECT   grp
        -- Calculate percentile rankings of interest (25%, 50%, 75%, 100%)
                        ,
                        [25th Percentile] = PERCENTILE_CONT(0.25) WITHIN GROUP ( ORDER BY VALUE ) 
                                OVER ( PARTITION BY grp ) ,
                        [50th Percentile] = PERCENTILE_CONT(0.50) WITHIN GROUP ( ORDER BY VALUE ) 
                                OVER ( PARTITION BY grp ) ,
                        [75th Percentile] = PERCENTILE_CONT(0.75) WITHIN GROUP ( ORDER BY VALUE ) 
                                OVER ( PARTITION BY grp ) ,
                        [100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP ( ORDER BY VALUE ) 
                                OVER ( PARTITION BY grp )
               FROM     Testdata
             )
    SELECT  grp
    -- A crosstab query to aggregate the results
            ,
            [25th Percentile] = MAX([25th Percentile]) ,
            [25th Percentile count] = COUNT(DISTINCT [25th Percentile]) ,
            [50th Percentile] = MAX([50th Percentile]) ,
            [50th Percentile count] = COUNT([50th Percentile]) ,
            [75th Percentile] = MAX([75th Percentile]) ,
            [75th Percentile] = COUNT(DISTINCT [75th Percentile]) ,
            [100th Percentile] = MAX([100th Percentile]) ,
            [100th Percentile COUNT] = COUNT([100th Percentile])
    FROM    a
    GROUP BY grp;



	END
    
GO
