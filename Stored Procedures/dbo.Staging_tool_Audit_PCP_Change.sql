SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Staging_tool_Audit_PCP_Change]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
/****** Script for SelectTopNRows command from SSMS  ******/
        SELECT  se.sig_event_id ,
                se.enterprise_id ,
                se.practice_id ,
                se.source1_id ,
                se.source2_id ,
                se.source3_id ,
                se.source4_id ,
                se.event_source_type ,
                se.sig_id ,
                se.sig_msg ,
                se.pre_mod ,
                se.post_mod ,
                se.create_timestamp ,
                se.created_by ,
                se.modify_timestamp ,
                se.modified_by ,
                se.row_timestamp ,
                se.group_id ,
                se.create_timestamp_tz ,
                se.modify_timestamp_tz ,
                [pre_mod] ,
                [post_mod] ,
                se.modify_timestamp
	--  ,se.source1_id
                ,
                per.first_name ,
                per.last_name ,
                um.first_name ,
                um.last_name AS Changed_by
        FROM    [10.183.0.94].NGProd.dbo.[sig_events] se
                INNER JOIN [10.183.0.94].NGProd.dbo.user_mstr um ON um.user_id = se.modified_by
                INNER JOIN [10.183.0.94].NGProd.dbo.person per ON per.person_id = se.source1_id


        WHERE -- se.source1_id = '6C29E756-955F-4EAC-B177-1338C8D13C3F' 
		  sig_msg LIKE 'Primary Care Provider Changed'
       --       AND post_mod LIKE '%searls%' ORDER BY se.created_by desc

  --'Primary Care'
 


        SELECT  *
        FROM    [10.183.0.94].NGProd.dbo.person
        WHERE   last_name LIKE '%bloch%';

    END;
GO
