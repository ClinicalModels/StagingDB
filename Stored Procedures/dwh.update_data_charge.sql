SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_data_charge]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

  

        DECLARE @dt_beg CHAR(8) ,
            @dt_end CHAR(8) ,
            @enc_rate_dept VARCHAR(50) ,
            @prac_id CHAR(4) ,
            @txn_proc_date VARCHAR(8);
        SET @dt_beg = '20100301';
        SET @dt_end = CONVERT(CHAR(8), GETDATE(), 112);
        SET @enc_rate_dept = 'encounter rate';
        SET @prac_id = '0001';
        SET @txn_proc_date = CONVERT(CHAR(8), GETDATE(), 112);
 

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        DECLARE @log TABLE
            (
              step_info VARCHAR(100) ,
              log_time DATETIME ,
              dur_secs INT
            );
        DECLARE @bt DATETIME ,
            @et DATETIME;

        SET @bt = GETDATE();
        INSERT  INTO @log
                ( step_info, log_time, dur_secs )
        VALUES  ( 'start process', @bt, 0 );
  
        IF OBJECT_ID('dwh.data_charge') IS NOT NULL
            DROP TABLE dwh.data_charge;

        SELECT  enc.enc_id ,
                chg.charge_id ,
                enc.Provider_id ,
                enc.person_id ,
                enc.location_id ,
                chg.service_item_id AS service_item_id ,
                [cpt4_code_id] ,
                [icd9cm_code_id] ,
                [icd9cm_code_id_2] ,
                [icd9cm_code_id_3] ,
                [icd9cm_code_id_4] ,
                chg.created_by ,
                enc.enc_bill_date AS enc_bill_date ,
                chg.closing_date AS chg_closing_date ,
                chg.modify_timestamp AS chg_mod_date ,
                [zero_bal_date] ,
                [credit_date] ,
                t.Txn_closing_date ,
                t.Txn_batch_date ,
                t.Txn_override_closing_date ,
                t.Txn_post_date ,
                days_chg_close_to_txn_close = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                        OR ISNULL(t.Txn_closing_date, 0) = 0 THEN 0
                                                   WHEN t.Txn_closing_date < chg.closing_date THEN 0
                                                   ELSE DATEDIFF(dd, CAST(chg.closing_date AS DATETIME),
                                                                 CAST(t.Txn_closing_date AS DATETIME))
                                              END ,
                days_chg_close_to_txn_post = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                       OR ISNULL(Txn_post_date, 0) = 0 THEN 0
                                                  WHEN Txn_post_date < chg.closing_date THEN 0
                                                  ELSE DATEDIFF(dd, CAST(chg.closing_date AS DATETIME),
                                                                CAST(Txn_post_date AS DATETIME))
                                             END ,
                days_chg_close_to_txn_batch = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                        OR ISNULL(t.Txn_batch_date, 0) = 0 THEN 0
                                                   WHEN t.Txn_batch_date < chg.closing_date THEN 0
                                                   ELSE DATEDIFF(dd, CAST(chg.closing_date AS DATETIME),
                                                                 CAST(t.Txn_batch_date AS DATETIME))
                                              END ,
                days_txn_batch_to_txn_post = CASE WHEN ISNULL(t.Txn_batch_date, 0) = 0
                                                       OR ISNULL(t.Txn_post_date, 0) = 0 THEN 0
                                                  WHEN t.Txn_post_date < t.Txn_batch_date THEN 0
                                                  ELSE DATEDIFF(dd, CAST(t.Txn_batch_date AS DATETIME),
                                                                CAST(t.Txn_post_date AS DATETIME))
                                             END ,
                days_enc_to_chg_close = CASE WHEN ISNULL(chg.closing_date, 0) = 0
                                                  OR ISNULL(enc.enc_bill_date, '') = '' THEN 0
                                             WHEN CAST(chg.closing_date AS DATE) < CAST(enc.enc_bill_date AS DATE)
                                             THEN 0
                                             ELSE DATEDIFF(dd, CAST(enc.enc_bill_date AS DATETIME),
                                                           CAST(chg.closing_date AS DATETIME))
                                        END ,
                CASE WHEN LEFT(chg.closing_date, 6) <= LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112), 6) THEN chg.amt
                     ELSE 0.00
                END AS chg_amt_enc_mon ,
                CASE WHEN LEFT(chg.closing_date, 6) > LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112), 6) THEN chg.amt
                     ELSE 0.00
                END AS chg_amt_later_mon ,
                amt = chg.amt ,
                cob1_amt = ISNULL(chg.cob1_amt, 0.00) ,
                cob2_amt = ISNULL(chg.cob2_amt, 0.00) ,
                cob3_amt = ISNULL(chg.cob3_amt, 0.00) ,
                pat_amt = ISNULL(chg.pat_amt, 0.00)
        INTO    dwh.data_charge
        FROM    [10.183.0.94].NGProd.dbo.charges chg
                INNER JOIN dwh.data_encounter enc ON enc.enc_id = chg.source_id
                                                             AND enc.person_id = chg.person_id
                LEFT JOIN ( SELECT  td.charge_id ,
                                    MAX(t.closing_date) AS Txn_closing_date ,
                                    MAX(t.post_date) AS Txn_post_date ,
                                    MAX(t.batch_date) AS Txn_batch_date ,
                                    MAX(t.override_closing_date) AS Txn_override_closing_date
                            FROM    dwh.data_encounter enc
                                    INNER JOIN [10.183.0.94].NGProd.dbo.charges chg ON enc.enc_id = chg.source_id
                                                                                       AND enc.person_id = chg.person_id
                                    INNER JOIN [10.183.0.94].NGProd.dbo.trans_detail td ON chg.charge_id = td.charge_id
                                    INNER JOIN [10.183.0.94].NGProd.dbo.transactions t ON td.trans_id = t.trans_id
                            GROUP BY td.charge_id
                          ) t ON chg.charge_id = t.charge_id
        WHERE   chg.closing_date IS NOT NULL
                AND enc.enc_id IS NOT NULL;

    END;
GO
