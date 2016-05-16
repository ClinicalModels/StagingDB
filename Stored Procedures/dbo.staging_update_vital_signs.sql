SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_vital_signs]
AS
BEGIN
 
 ;with vitals as
  (
  SELECT 
         [person_id]
		 ,cast(convert(char(6),create_timestamp,112)+'01' as date) as seq_date

      , [bp_systolic] as bp_sys
	  , [bp_diastolic] as bp_dia
      ,ROW_NUMBER() OVER
         (
             PARTITION BY person_id,convert(char(6), create_timestamp,112)
             ORDER BY create_timestamp DESC
         ) AS Recency

 
  FROM [10.183.0.94].NGPROD.dbo.[vital_signs_]

  )
  select  pv.person_id, bp_sys,pv.bp_dia, CurMon_Pt_Age

   from  staging_ng_data_person_ pd left join (select person_id, bp_sys, bp_dia,seq_date from vitals where recency=1) pv on pd.person_id = pv.person_id and pd.seq_date =pv.seq_date where pv.bp_dia is not null
END
GO
