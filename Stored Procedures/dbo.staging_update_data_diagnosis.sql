SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_data_diagnosis]

as
BEGIN
/****** Script for SelectTopNRows command from SSMS  ******/

--Build Diagnoses DataMart

declare @build_dt_start varchar(8), @build_dt_end varchar(8), @Build_counter varchar(8)

set @build_dt_start = CONVERT(varchar(8),GETDATE(),112) --This routine will build current and hx data from begin to end date 
set @build_dt_end =CONVERT(varchar(8),GETDATE(),112)

set @build_dt_start = '20100101'
--set @build_dt_end =   '20100202'

--set @build_dt_end =   '20150701'


IF OBJECT_ID('staging_ng_link_person_diagnosis_') IS NOT NULL DROP TABLE staging_ng_link_person_diagnosis_
IF OBJECT_ID('staging_ng_data_diagnosis_') IS NOT NULL DROP TABLE staging_ng_data_diagnosis_
IF OBJECT_ID('staging_ng_dim_diagnosis_') IS NOT NULL DROP TABLE staging_ng_dim_diagnosis_


SELECT per.[per_mon_id]
	  ,cast(CONVERT(char(6), pd.[create_timestamp], 112)+'01' as date) as seq_date
      ,IDENTITY(INT, 1, 1)  as Dx_id
	  ,pd.[diagnosis_code_id]
      ,pd.[description] as ICD9_Name
       
	 ,pd.[person_id]
      --,pd.[icd9cm_code_id]
      ,pd.[location_id]
      ,pd.[provider_id]
	  ,   CONCAT(pd.[diagnosis_code_id],' - ',pd.[description]) as Diag_Full_Name
        
  INTO staging_ng_data_diagnosis_
  FROM   [10.183.0.94].NGPROD.dbo.[patient_diagnosis] pd inner join staging_ng_data_person_ per on pd.person_id = per.person_id and per.seq_date = cast(CONVERT(char(6), pd.[create_timestamp], 112)+'01'  as date)
   inner join staging_ng_location_ loc on loc.location_id = pd.location_id -- added join to location table as some bad records introduced with poor location data

  where (pd.create_timestamp >= cast(@build_dt_start as date)) and (pd.create_timestamp <= cast(@build_dt_end as date))


  select  per_mon_id  ,  Dx_id         
	 ,[person_id]
	 ,seq_date
	 ,Diag_Full_Name
     ,	 [diagnosis_code_id]
      ,[location_id]
      ,[provider_id]
	  into staging_ng_link_person_diagnosis_

	    from staging_ng_data_diagnosis_



  select  distinct 
       
		   Diag_Full_Name
          , [diagnosis_code_id]
		   , ICD9_Name
              
	 
	  
 into  staging_ng_dim_diagnosis_
  from staging_ng_data_diagnosis_
END
GO
