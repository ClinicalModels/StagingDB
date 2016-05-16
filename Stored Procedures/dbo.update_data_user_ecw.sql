SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Julius Abate>
-- Create date: <April 19, 2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_user_ecw]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF OBJECT_ID('dbo.data_user_ecw') IS NOT NULL
		DROP TABLE dbo.data_user_ecw

    SELECT * INTO dbo.data_user_ecw
	FROM OPENQUERY(ECWDB, '
		 SELECT 
			us.uid AS user_id_ecw,
			us.ufname AS first_name, 
			us.ulname AS last_name,
			CASE
				WHEN us.ufname LIKE '''' THEN ulname
				ELSE CONCAT(us.ulname,'', '',ufname)
			END
				AS FullName,
			UserType
		 FROM mobiledoc.users us
		 LEFT JOIN mobiledoc.patients ON us.uid = patients.pid 
		 WHERE patients.pid IS NULL')


END
GO
