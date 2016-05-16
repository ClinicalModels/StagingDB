SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_data_charge]


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
  
IF OBJECT_ID('staging_ng_data_charge_') IS NOT NULL DROP TABLE staging_ng_data_charge_

SELECT
   enc.enc_id
  ,chg.charge_id 
  ,enc.provider_id
  ,enc.person_id
  ,enc.location_id
 
  ,chg.service_item_id as service_item_id
 
      , [cpt4_code_id]
      ,[icd9cm_code_id]
      ,[icd9cm_code_id_2]
      ,[icd9cm_code_id_3]
      ,[icd9cm_code_id_4]
	  
	,chg.created_by
  ,enc.enc_bill_date as enc_bill_date
  ,chg.closing_date  as chg_closing_date

	   ,chg.modify_timestamp as chg_mod_date
      
      ,[zero_bal_date]
      ,[credit_date]
 
 
 
    ,t.Txn_closing_date 
    ,t.Txn_batch_date 
	,t.Txn_override_closing_date
    ,t.Txn_post_date
  




    ,days_chg_close_to_txn_close = case 
    when isnull(chg.closing_date,0)= 0 or isnull(t.Txn_closing_date,0) = 0 then 0
  when t.Txn_closing_date  < chg.closing_date then 0
  else DATEDIFF(dd, cast(chg.closing_date as datetime), CAST(t.Txn_closing_date as datetime)) end
    
	,days_chg_close_to_txn_post = case 
    when isnull(chg.closing_date,0)= 0 or isnull(Txn_post_date,0)= 0 then 0
  when Txn_post_date < chg.closing_date then 0
  else DATEDIFF(dd, cast(chg.closing_date as datetime), CAST(Txn_post_date as datetime)) end

  ,days_chg_close_to_txn_batch = case 
    when isnull(chg.closing_date,0)= 0 or isnull(t.Txn_batch_date ,0)= 0 then 0
  when t.Txn_batch_date < chg.closing_date then 0
  else DATEDIFF(dd, cast(chg.closing_date as datetime), CAST(t.Txn_batch_date  as datetime)) end

  ,days_txn_batch_to_txn_post = case 
    when isnull(t.Txn_batch_date ,0)= 0 or isnull(t.Txn_post_date ,0)= 0 then 0
  when t.Txn_post_date < t.Txn_batch_date  then 0
  else DATEDIFF(dd, cast(t.Txn_batch_date  as datetime), CAST(t.Txn_post_date  as datetime)) end
  
  ,days_enc_to_chg_close = case 
    when isnull(chg.closing_date,0)= 0 or isnull(enc.enc_bill_date,'')=''  then 0
  when cast(chg.closing_date as date) < cast(enc.enc_bill_date as date) then 0
  else DATEDIFF(dd, cast(enc.enc_bill_date as datetime), CAST(chg.closing_date as datetime)) end
 
 

 , CASE when left(chg.closing_date,6) <= left(convert(char(8), enc.enc_bill_date, 112),6)
       then chg.amt ELSE 0.00 END as chg_amt_enc_mon
  ,CASE when  left(chg.closing_date,6) > left(convert(char(8), enc.enc_bill_date, 112),6)
       then chg.amt ELSE 0.00 END as chg_amt_later_mon
  
  
  ,amt = chg.amt 





  ,cob1_amt = isnull(chg.cob1_amt,0.00)
  ,cob2_amt = isnull(chg.cob2_amt,0.00)
  ,cob3_amt = isnull(chg.cob3_amt,0.00)
  ,pat_amt = isnull(chg.pat_amt,0.00)
  
into staging_ng_data_charge_
FROM [10.183.0.94].NGPROD.dbo.charges chg 
inner join staging_ng_data_encounter_ enc
    on enc.enc_id = chg.source_id
   and enc.person_id = chg.person_id

left JOIN (

select td.charge_id, max(t.closing_date) as Txn_closing_date, max(t.post_date) as Txn_post_date, max(t.batch_date) as Txn_batch_date, max(t.override_closing_date) as Txn_override_closing_date

 FROM staging_ng_data_encounter_ enc
INNER join [10.183.0.94].NGPROD.dbo.charges chg
    on enc.enc_id = chg.source_id
   and enc.person_id = chg.person_id
inner join [10.183.0.94].NGPROD.dbo.trans_detail td
    on chg.charge_id = td.charge_id
inner join [10.183.0.94].NGPROD.dbo.transactions t
    on td.trans_id = t.trans_id 
	group by td.charge_id
	) t on chg.charge_id = t.charge_id 
    

where chg.closing_date  is not null and enc.enc_id is not null

END
GO
