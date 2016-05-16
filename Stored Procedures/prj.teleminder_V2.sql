SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [prj].[teleminder_V2]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 --Phone Number First Name Last Name 5105751616|Guduru Jyothi|Reddy|O|A||163493|OV
	--Patient Phone Number	Patient Last Name	Patient First Name	Patient Account Number
WITH teleminder AS
(
 SELECT e.[Patient First Name] AS firstname,e.[Patient Last Name] AS lastname,e.[Patient Account Number] AS act_nbr,e.[Patient Phone Number] AS DayPhone
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		  'Excel 12.0;Database=C:\temp\BrooksidePortalCallList.xls', [Sheet1$]) AS e
)
 SELECT REPLACE(REPLACE(t.firstname,'-',' '),'"','') AS first_name,
  REPLACE(REPLACE(t.lastname,'-',' '),'"','')  AS last_name,
  REPLACE(REPLACE(REPLACE(replace(t.DayPhone,'-',''),' ',''),'(',''),')','') AS day_phone,
  t.act_nbr AS MED_REC_NBR
 INTO #tempTable
 FROM teleminder AS t


 SELECT * FROM #tempTable

 	SET NOCOUNT ON;
	
	DECLARE @FILENAME VARCHAR(100)
    DECLARE @DESTINATION VARCHAR(200)
	DECLARE @SQL VARCHAR(1000)
	

    SET @DESTINATION = 'C:\Temp\'
    SET @FILENAME = @DESTINATION+'LMC_TELEMINDER.TXT'


 IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[CHCN_TELEMINDER]') AND OBJECTPROPERTY(ID, N'ISUSERTABLE') = 1) 
	DROP TABLE [DBO].[CHCN_TELEMINDER]
CREATE TABLE TELEMINDER (RECORD VARCHAR(1000))


INSERT INTO TELEMINDER (RECORD) 
 SELECT day_phone +'|'
	+first_name +'|'
	+last_name +'|'
	+'O'+'|'
	+'A'+'||'
	+ISNULL(MED_REC_NBR,'')+'|'
	+'OV'
 FROM #tempTable
 
    SET @DESTINATION = 'C:\Temp\teleminder\'
    SET @FILENAME = @DESTINATION+'LMC_TELEMINDER.TXT'

--write database table to txt file   
SELECT @SQL='BCP   [Staging_Ghost].[dbo].[TELEMINDER]   OUT  '+@FILENAME+' -c -t -T -S '+@@SERVERNAME
EXEC master..XP_CMDSHELL @SQL
--drop table 
  DROP TABLE [DBO].[TELEMINDER]
  DROP TABLE #tempTable
END
GO
