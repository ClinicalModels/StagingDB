SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dwh].[update_data_diagnosis_v2]
AS
  BEGIN
/****** Script for SelectTopNRows command from SSMS  ******/

--Build Diagnoses DataMart

        DECLARE @build_dt_start VARCHAR(8) ,
            @build_dt_end VARCHAR(8) ,
            @Build_counter VARCHAR(8);

        SET @build_dt_start = CONVERT(VARCHAR(8), GETDATE(), 112); --This routine will build current and hx data from begin to end date 
        SET @build_dt_end = CONVERT(VARCHAR(8), GETDATE(), 112);

        SET @build_dt_start = '20100101';
--set @build_dt_end =   '20100202'

--set @build_dt_end =   '20150701'


 
        IF OBJECT_ID('dwh.data_diagnosis') IS NOT NULL
            DROP TABLE dwh.data_diagnosis;


        SELECT  
                CAST(CONVERT(CHAR(6), pd.[create_timestamp], 112) + '01' AS DATE) AS first_mon_date ,
                pd.[create_timestamp],
				IDENTITY( INT, 1, 1 )  AS Dx_id ,
                pd.[diagnosis_code_id] ,
                COALESCE(pd.[description],'') AS ICD9_Name ,
                pd.[person_id],
				pd.enc_id,
      
	  --,pd.[icd9cm_code_id]
                
                pd.[location_id] ,
                pd.[provider_id] ,
                COALESCE(CONCAT(pd.[diagnosis_code_id], ' - ', pd.[description]),'') AS Diag_Full_Name
        INTO    dwh.data_diagnosis
        FROM    [10.183.0.94].NGProd.dbo.[patient_diagnosis] pd
                -- previously had added join to location table as some bad records introduced with poor location data
        WHERE   ( pd.create_timestamp >= CAST(@build_dt_start AS DATE) )
                AND ( pd.create_timestamp <= CAST(@build_dt_end AS DATE) );
;

--ALT Version
/*select 
med_rec_nbr + 0 prt_no
,case	when IsDate(date_diagnosed) = 1 and IsNull(date_diagnosed,'') != '' then   convert(datetime,pd.date_diagnosed) 
		when IsDate(date_onset_sympt) = 1 and IsNull(date_onset_sympt,'') != '' then   convert(datetime,pd.date_onset_sympt)
		else DATEADD(dd, DATEDIFF(dd, 0, enc_timestamp), 0)
end eff_dt
,convert(datetime, case when date_resolved = '' then '29991231' else date_resolved end) thru_dt
,icd9cm_code_id icd9_code
,Desc_txt icd9_description
, pd.created_by, pd.provider_id
into #diag
from PacelinkDW.patient_diagnosis pd with (nolock) 
inner join PacelinkDW.patient_encounter pe with (nolock) on pd.enc_id = pe.enc_id
inner join PacelinkDW.patient p with (nolock) on pd.person_id = p.person_id and p.med_rec_nbr + 0 > 100
Join   DW.Diag_Ref r on r.Diag_Cd = pd.icd9cm_code_id
 where 
icd9cm_code_id <> ''
and pd.practice_id in ('0001','0002')
*/


    END;
GO
