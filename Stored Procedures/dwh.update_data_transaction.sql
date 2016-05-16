SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_data_transaction]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

     
        IF OBJECT_ID('dwh.data_transaction') IS NOT NULL
            DROP TABLE dwh.data_transaction;

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


 

        SELECT  enc.enc_id ,
                enc.location_id ,
                enc.person_id ,
                chg.charge_id ,
                txn.trans_id ,
                enc.provider_id ,
                txn.payer_id ,
                txn.created_by ,
                txn.tran_code_id ,
                rcl.reason_code_id ,
                enc.enc_bill_date AS enc_bill_date ,
                chg.chg_closing_date ,
                chg.txn_batch_date ,
                txn.batch_date ,
                chg.txn_post_date ,
                txn.post_date ,
                chg.txn_closing_date ,
                txn.closing_date ,
                tcm.type ,
                adj_amt_enc_mon = CASE WHEN tcm.type = 'A'
                                            AND LEFT(txn.post_date, 6) <= LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112),
                                                                               6) THEN td.adj_amt
                                  END ,
                adjust_pd = CASE WHEN tcm.type = 'A'
                                      AND LEFT(txn.post_date, 6) <= LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112), 6)
                                 THEN td.paid_amt
                            END ,
                pymt_adj = CASE WHEN tcm.type = 'C'
                                     AND LEFT(txn.post_date, 6) <= LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112), 6)
                                THEN td.adj_amt
                           END ,
                pymts_amt_enc_mon = CASE WHEN tcm.type = 'C'
                                              AND LEFT(txn.post_date, 6) <= LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112),
                                                                                 6) THEN td.paid_amt
                                    END ,
                adj_amt_later_mon = CASE WHEN tcm.type = 'A'
                                              AND LEFT(txn.post_date, 6) > LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112),
                                                                                6) THEN td.adj_amt
                                    END ,
                adjust_pd_later = CASE WHEN tcm.type = 'A'
                                            AND LEFT(txn.post_date, 6) > LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112),
                                                                              6) THEN td.paid_amt
                                  END ,
                pymt_adj_later = CASE WHEN tcm.type = 'C'
                                           AND LEFT(txn.post_date, 6) > LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112), 6)
                                      THEN td.adj_amt
                                 END ,
                pymts_amt_later_mon = CASE WHEN tcm.type = 'C'
                                                AND LEFT(txn.post_date, 6) > LEFT(CONVERT(CHAR(8), enc.enc_bill_date, 112),
                                                                                  6) THEN td.paid_amt
                                      END ,
                refunds_amt = CASE WHEN tcm.type = 'R' THEN td.adj_amt
                              END ,
                td.paid_amt AS paid_amt ,
                td.adj_amt AS adj_amt
        INTO    dwh.data_transaction
        FROM    [10.183.0.94].NGProd.dbo.trans_detail td
                INNER JOIN [10.183.0.94].NGProd.dbo.transactions txn ON td.trans_id = txn.trans_id
                INNER JOIN dwh.data_charge chg ON td.charge_id = chg.charge_id
                INNER JOIN dwh.data_encounter enc ON enc.enc_id = chg.enc_id
                                                     AND enc.person_id = chg.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.tran_code_mstr tcm ON txn.tran_code_id = tcm.tran_code_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.reason_code_links rcl ON td.trans_id = rcl.trans_id
                                                                            AND td.charge_id = rcl.charge_id
        WHERE   td.post_ind = 'Y'
                AND txn.post_date IS NOT NULL
                AND enc.enc_id IS NOT NULL
                AND ISNULL(txn.closing_date, '') != ''
                AND txn.closing_date <= @txn_proc_date;
  

    END;
GO
