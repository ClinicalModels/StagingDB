SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [prj].[Pharmcy_1510_teleminder]
AS
BEGIN

	
	WITH teleLanguage AS
(
  
		  SELECT REPLACE(Excell.[SSN],'-','') AS SSN,Excell.[Pat Name] AS Fullname,p.language,[Day Phone] AS DayPhone,[Birth Dt] AS BirthDt,Excell.[Chart Number] AS medicalNumber,
		  ROW_NUMBER() OVER(PARTITION BY Excell.[SSN] ORDER By Excell.[Pat Name])As Rank1
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		  'Excel 12.0;Database=C:\temp\MedicareCallList.xlsx', [Sheet1$]) AS Excell
		 left JOIN [10.183.0.94].NGProd.dbo.person  p
		  on REPLACE(Excell.[SSN],'-','')=p.ssn
		WHERE REPLACE(Excell.[SSN],'-','') IS NOT NULL

),
 teleminder AS(
SELECT d.SSN,d.fullname,d.language,d.DayPhone,d.BirthDt,d.medicalNumber
FROM (SELECT teleLanguage.SSN,teleLanguage.fullname,teleLanguage.Rank1,teleLanguage.BirthDt,teleLanguage.DayPhone,teleLanguage.language,teleLanguage.medicalNumber FROM teleLanguage WHERE teleLanguage.Rank1=1) AS d
UNION 
   SELECT REPLACE(Excell.[SSN],'-','') AS SSN,Excell.[Pat Name] AS fullname,per.language,[Day Phone] AS DayPhone,[Birth Dt] AS BirthDt,Excell.[Chart Number] AS medicalNumber
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		  'Excel 12.0;Database=C:\temp\MedicareCallList.xlsx', [Sheet1$]) AS Excell
		  LEFT outer JOIN [10.183.0.94].NGProd.dbo.person AS per
		  ON REPLACE(Excell.[SSN],'-','')=per.ssn 
		  WHERE  Excell.[SSN] IS NULL
		  
 )

 SELECT REPLACE(SUBSTRING(t.fullname, 1, CHARINDEX(' ', t.fullname) - 1),',','') AS first_name,
  SUBSTRING(t.fullname, CHARINDEX(' ',t.fullname) + 1, LEN(t.fullname)) AS last_name,
  REPLACE(REPLACE(REPLACE(replace(t.DayPhone,'-',''),' ',''),'(',''),')','') AS day_phone,
  t.medicalNumber AS MED_REC_NBR,REPLACE(CONVERT(DATE,t.BirthDt,101),'-','/') AS birthday,t.language AS Lang
 INTO #tempTable
 FROM teleminder AS t

 	SET NOCOUNT ON;
	
	DECLARE @FILENAME VARCHAR(100)
    DECLARE @DESTINATION VARCHAR(200)
	DECLARE @SQL VARCHAR(1000)
	

    SET @DESTINATION = 'C:\Temp\'
    SET @FILENAME = @DESTINATION+'LMC_TELEMINDER.TXT'


 IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[CHCN_TELEMINDER]') AND OBJECTPROPERTY(ID, N'ISUSERTABLE') = 1) 
	DROP TABLE [DBO].[CHCN_TELEMINDER]
CREATE TABLE CHCN_TELEMINDER (RECORD VARCHAR(1000))


INSERT INTO CHCN_TELEMINDER (RECORD) 
 SELECT day_phone +'|'
	+ last_name +'|'
	+ first_name +'|'
	+'O'+'|'
	+CASE REPLACE(Lang,'*','') WHEN 'English' THEN 'A' WHEN 'Spanish' THEN 'S' ELSE 'A' END+'|'
	+RIGHT(left(birthday, 7),2)+'/'+RIGHT(left(birthday,10),2)+'/'+left(birthday,4)+'|'
	+ISNULL(MED_REC_NBR,'')+'|'
	+'OV'
 FROM #tempTable
 
    SET @DESTINATION = 'C:\Temp\'
    SET @FILENAME = @DESTINATION+'LMC_TELEMINDER.TXT'

--write database table to txt file   
SELECT @SQL='BCP   [Staging_Ghost].[dbo].[CHCN_TELEMINDER]   OUT  '+@FILENAME+' -c -t -T -S '+@@SERVERNAME
EXEC master..XP_CMDSHELL @SQL
--drop table 
  DROP TABLE [DBO].[CHCN_TELEMINDER]
  DROP TABLE #tempTable
END
GO
