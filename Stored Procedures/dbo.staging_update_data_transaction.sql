SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_data_transaction]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  

declare @dt_beg char(8), @dt_end char(8), @enc_rate_dept varchar(50), @prac_id char(4)
  ,@txn_proc_date varchar(8)
set @dt_beg = '20100301'
set @dt_end = convert(char(8),getdate(),112)
set @enc_rate_dept = 'encounter rate'
set @prac_id = '0001'
set @txn_proc_date = convert(char(8),getdate(),112)
 

set transaction isolation level read uncommitted

declare @log table (step_info varchar(100), log_time datetime, dur_secs int)
declare @bt datetime, @et datetime

set @bt = GETDATE()
insert into @log (step_info, log_time, dur_secs) 
  values ('start process', @bt, 0)


    
IF OBJECT_ID('staging_ng_data_transaction_') IS NOT NULL DROP TABLE staging_ng_data_transaction_

SELECT
   enc.enc_id
  ,enc.location_id
  ,enc.person_id
  ,chg.charge_id
  ,txn.trans_id
  ,enc.provider_id
  ,txn.payer_id
  ,txn.created_by 
  ,txn.tran_code_id 
  ,rcl.reason_code_id
   ,enc.enc_bill_date as enc_bill_date
  ,chg.chg_closing_date
  ,chg.txn_batch_date
  ,txn.batch_date
  ,chg.txn_post_date
  ,txn.post_date
  ,chg.txn_closing_date
  ,txn.closing_date
 
  ,tcm.type

   ,adj_amt_enc_mon = case WHEN  tcm.type = 'A'
      and left(txn.post_date,6) <= left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.adj_amt end
  ,adjust_pd = case WHEN  tcm.type = 'A'
      and left(txn.post_date,6) <= left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.paid_amt end
  ,pymt_adj = case WHEN tcm.type = 'C'
      and left(txn.post_date,6) <= left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.adj_amt end
  ,pymts_amt_enc_mon  = case WHEN tcm.type = 'C'
      and left(txn.post_date,6) <= left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.paid_amt end
  ,adj_amt_later_mon = case WHEN  tcm.type = 'A'
      and left(txn.post_date,6) > left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.adj_amt end
  ,adjust_pd_later = case WHEN  tcm.type = 'A'
      and left(txn.post_date,6) > left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.paid_amt end
  ,pymt_adj_later = case WHEN tcm.type = 'C'
      and left(txn.post_date,6) > left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.adj_amt end
  ,pymts_amt_later_mon = case WHEN tcm.type = 'C'
      and left(txn.post_date,6) > left(convert(char(8), enc.enc_bill_date, 112),6)
    then td.paid_amt end
  ,refunds_amt = case WHEN tcm.type = 'R' then td.adj_amt end
  ,td.paid_amt as paid_amt
  ,td.adj_amt  as adj_amt


into staging_ng_data_transaction_
from [10.183.0.94].NGPROD.dbo.trans_detail td
      inner join [10.183.0.94].NGPROD.dbo.transactions txn
    ON td.trans_id = txn.trans_id
INNER join staging_ng_data_charge_ chg
       on  td.charge_id = chg.charge_id
inner join  staging_ng_data_encounter_ enc
  on enc.enc_id = chg.enc_id
    and enc.person_id = chg.person_id
    
 
  left JOIN [10.183.0.94].NGPROD.dbo.tran_code_mstr tcm
    ON txn.tran_code_id = tcm.tran_code_id
  left join [10.183.0.94].NGPROD.dbo.reason_code_links rcl
    on td.trans_id = rcl.trans_id
      and td.charge_id = rcl.charge_id
 
where td.post_ind = 'Y'
  and txn.post_date is not null
  and enc.enc_id is not null
  and ISNULL(txn.closing_date,'') != ''
  and txn.closing_date <= @txn_proc_date
  

END
GO
