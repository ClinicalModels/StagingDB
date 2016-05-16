SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [prj].[compliance_1510_audits v1]
	-- Add the parameters for the stored procedure here
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;



     


        SELECT  ml.mstr_list_item_desc AS medical_home,
				com.name ,
				pat.med_rec_nbr,
                CONVERT(DATE,com.[Crt Dt],112) AS access_date ,
				CONVERT(CHAR(6),com.[Crt Dt],112) AS access_month,

                per.first_name,per.last_name,per.home_phone,per.alt_phone,
				per.address_line_1,per.address_line_2,per.city,per.state,per.zip
        FROM    prj.compliance_1510_audits com
                LEFT JOIN [10.183.0.94].NGProd.dbo.person per ON com.Per_Nbr = per.person_nbr
                LEFT JOIN [10.183.0.94].NGProd.dbo.person_ud ud ON per.person_id = ud.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.patient pat ON per.person_id = pat.person_id
                LEFT JOIN [10.183.0.94].NGProd.dbo.mstr_lists ml ON ud.ud_demo3_id = ml.mstr_list_item_id
				WHERE com.Per_nbr IS NOT null;

    END;
GO
