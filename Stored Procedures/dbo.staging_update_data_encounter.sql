SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_data_encounter]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  

declare @dt_beg char(8), @dt_end char(8), @prac_id char(4)
  
set @dt_beg = convert(char(8),DATEADD(dd,-2,getdate()),112)
set @dt_end = convert(char(8),getdate(),112)

set @dt_beg = '20100101'

     IF OBJECT_ID('dbo.staging_ng_data_encounter_ ') IS NOT NULL
            DROP TABLE dbo.staging_ng_data_encounter_ ;

SELECT distinct chg.source_id, qual_enc_ct = 1

into #qualenc
from [10.183.0.94].NGPROD.dbo.charges chg
  inner join  [10.183.0.94].NGPROD.dbo.patient_encounter  enc
    on chg.source_id = enc.enc_id
  inner join [10.183.0.94].NGPROD.dbo.service_item_mstr sim
    on chg.service_item_id = sim.service_item_id
      and chg.service_item_lib_id = sim.service_item_lib_id
      and convert(varchar(8), enc.billable_timestamp,112) >= sim.eff_date
      and convert(varchar(8), enc.billable_timestamp,112) <= sim.exp_date
where chg.link_id is null
  and (
    sim.fqhc_enc_ind = 'Y'
    or sim.self_pay_fqhc_ind = 'Y'
    or sim.sliding_fee_fqhc_ind = 'Y'
    ) and convert(char(8), enc.modify_timestamp, 112) BETWEEN @dt_beg and @dt_end and (convert(varchar(8), enc.billable_timestamp,112)>'20100301') -- This 20100301 is the merrit encounter import date

	
/*
delete 
from dbo.staging_ng_data_encounter_ 
where enc_id in (select enc_id from [10.183.0.94].NGPROD.dbo.patient_encounter  where modify_timestamp >= cast(@dt_beg as date) and modify_timestamp<= cast ( @dt_end as date))


insert into staging_ng_data_encounter_  (
          [enc_id]
		--  ,enc_nbr
      ,[location_id]
      ,[Provider_id]
      ,[person_id]
      ,[created_by]
      ,[enc_status]
	  ,[enc_cr_date]
      ,[enc_md_date]
	  ,[enc_bill_date]
      ,[first_mon_date]
      ,[billable_enc_ct]
      ,[qual_enc_ct]
	  ,[enc_count])
	
	*/	   
select 
   enc.enc_id
--   ,enc.enc_nbr
  ,enc.location_id
  ,enc.rendering_provider_id  as provider_id
  ,enc.person_id
  ,enc.created_by
  ,enc.enc_status
  ,cast(enc.create_timestamp as date) as Enc_cr_date
  ,cast(enc.modify_timestamp as date) as Enc_md_date
  ,enc_bill_date = Cast( enc.billable_timestamp as date)
  ,first_mon_date= cast(convert( char(6), enc.billable_timestamp,112)+'01' as date)
  ,billable_enc_ct = case when enc.billable_ind = 'Y' THEN 1 ELSE 0 END 
  ,case when ISNULL(q.qual_enc_ct,0) = 1 then 1 else 0  end as qual_enc_ct   
  ,enc_count = 1


  into staging_ng_data_encounter_
  
from  [10.183.0.94].NGPROD.dbo.patient_encounter enc  left join #qualenc q on q.source_id =enc.enc_id
where convert(char(8), enc.modify_timestamp , 112) BETWEEN @dt_beg and @dt_end and  (convert(varchar(8), enc.billable_timestamp,112)>'20100301') -- This 20100301 is the merrit encounter import date

drop table #qualenc

END



GO
