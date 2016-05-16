SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Hanife>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dwh].[update_data_PAQ_test] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
--Patient Document
 SELECT  d.paq_provider_id,
      e.person_id,  
      e.enc_id,  
      e.enc_timestamp,  
      d.document_id   As UniqueID,  
      d.document_desc As ItemDesc,  
      d.document_file As ItemFile,  
      NULL            As ItemName,  
      d.file_format   As Format,  
      d.created_by,  
      d.create_timestamp,  
      d.modified_by,  
      d.modify_timestamp,  
      d.app_created_by,  
      d.create_timestamp_tz,  
      d.modify_timestamp_tz,  
      e.enc_timestamp_tz,  
      s.perm_pos,  
      NULL,  
      NULL,  
      d.practice_id  
   FROM [10.183.0.94].NGPROD.dbo.patient_encounter e  
   INNER JOIN [10.183.0.94].NGPROD.dbo.patient_documents d  
      ON e.enterprise_id = d.enterprise_id  
      AND e.practice_id = d.practice_id  
      AND e.enc_id = d.enc_id  
     -- AND e.enterprise_id = @ente_id  
      AND ISNULL(d.paq_provider_id,'00000000-0000-0000-0000-000000000000') = d.paq_provider_id  
      --AND d.signoff_status = @sign  
   LEFT OUTER JOIN [10.183.0.94].NGPROD.dbo.security_items s  
      ON d.document_desc = s.description  
      AND s.item_type ='D'   
      AND s.delete_ind ='N'  

    
	
END
GO
