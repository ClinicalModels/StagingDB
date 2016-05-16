SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [prj].[information_1102_phi]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    
	SET NOCOUNT ON;
	;WITH phi AS
(
  
		  SELECT *
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		  'Excel 12.0;Database=C:\temp\PortalFebCallListFinal.xlsx', [Sheet1$]) AS Excell
		

)SELECT * INTO #tempTable FROM phi;

SELECT * FROM #tempTable
	DECLARE @FILENAME VARCHAR(100)
    DECLARE @DESTINATION VARCHAR(200)
	DECLARE @SQL VARCHAR(1000)
	

    SET @DESTINATION = 'C:\Temp\'
    SET @FILENAME = @DESTINATION+'February_appointment.TXT'


 IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[PHI]') AND OBJECTPROPERTY(ID, N'ISUSERTABLE') = 1) 
	DROP TABLE [DBO].[PHI]
CREATE TABLE PHI(RECORD VARCHAR(1000))


SELECT * FROM #tempTable

-- Email Addr Loc Name Pat Name Per Nbr Expired Day Phone Md Rc  

--5105282556|Muhammad|Abbas|O|A||32|OV
INSERT INTO PHI(RECORD) 
 SELECT REPLACE(REPLACE(REPLACE(REPLACE([Day Phone],')',''),'(',''),'-',''),' ','') +'|'+SUBSTRING([Pat Name],(CHARINDEX(',',[Pat Name]))+2,((LEN(REPLACE(REPLACE([Pat Name],',',''),' ','')))-(CHARINDEX(',',[Pat Name])))+20) +'|'
	+SUBSTRING([Pat Name],0,(CHARINDEX(',',[Pat Name]))) +'|'
	+'O'+'|'
	+'A'+'||'
	+[Md Rc]+'|'
	+'OV'
 FROM #tempTable

--5105282556|Muhammad|Abbas|O|A||32|OV
--INSERT INTO PHI(RECORD) 
-- SELECT CONVERT(NVARCHAR(30),CONVERT(NUMERIC,[Phone]))+'|'+[First Name] +'|'+[Last Name] +'|'
--	+'O'+'|'
--	+'A'+'||'
--	+CONVERT(NVARCHAR(30),[Chart#])+'|'
--	+'OV'
-- FROM #tempTable
 
 

    SET @DESTINATION = 'C:\Temp\'
    SET @FILENAME = @DESTINATION+'February_appointment.TXT'

--write database table to txt file   
SELECT @SQL='BCP   [Staging_Ghost].[dbo].[PHI]   OUT  '+@FILENAME+' -c -t -T -S '+@@SERVERNAME
EXEC master..XP_CMDSHELL @SQL
--drop table 
  DROP TABLE [DBO].[PHI]
  DROP TABLE #tempTable

  
END
GO
