SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_PAQ_data]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



--Provider Approval Queue
IF OBJECT_ID('staging_ng_PAQ_data_') IS NOT NULL DROP TABLE staging_ng_PAQ_data_

SELECT  [unique_id]
      ,q.[enterprise_id]
      ,q.[practice_id]
      ,q.[provider_id]
      ,q.[person_id]
      ,q.[enc_id]
      ,q.[item_type]
      ,q.[item_id]
      ,q.[item_name]
      ,q.[item_file]
      ,q.[item_format]
      ,q.[signoff_user_id]
      ,q.[signoff_action]
      ,q.[signoff_desc]
      ,q.[reassigned_provider_id]
      ,q.[created_by]
      ,q.[modified_by]
      ,q.[create_timestamp]
      ,q.[modify_timestamp]
      ,q.[row_timestamp]
      ,q.[app_created_by]
      ,q.[create_timestamp_tz]
      ,q.[modify_timestamp_tz]
	  , Cast(q.create_timestamp as date) as signoffdate
	  ,um.provider_id as signoffProvider
	  ,case when um.provider_id = q.provider_id then  1 else 0 end as nbr_PAQ_by_Provider
	  
     ,case when um.provider_id != q.provider_id then  1 else 0 end as nbr_PAQ_by_Covering_Provider
	 ,case when enc_id is not null then 1 else 0 end as nbr_Realted_to_encounter_flg
	 ,case when reassigned_provider_id is not null then 1 else 0 end as nbr_PAQ_Reassigned_to_dif_Provider_flg

--into staging_ng_PAQ_data_

  FROM  [10.183.0.94].NGPROD.dbo.[paq_signoff_history] q left join  [10.183.0.94].NGPROD.dbo.user_mstr um on q.created_by = um.user_id 



END
GO
