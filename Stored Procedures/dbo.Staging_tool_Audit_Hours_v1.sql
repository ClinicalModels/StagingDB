SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Staging_tool_Audit_Hours_v1]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
/****** Script for SelectTopNRows command from SSMS  ******/


--SELECT user_id FROM [10.183.0.94].NGProd.dbo.user_mstr um WHERE um.last_name LIKE '%thach%'


WITH filter1 AS ( 

SELECT * ,  DATEPART(dw,se.create_timestamp) AS DayNumber, DATEPART(hh,se.create_timestamp) AS DayHour, DATENAME(dw,se.create_timestamp) AS DayName, IIF(DATEPART(hh,se.create_timestamp) >=8 AND DATEPART(hh,se.create_timestamp) <=12, 1,0) AS  AMWORK,   
IIF(DATEPART(hh,se.create_timestamp) >=12 AND DATEPART(hh,se.create_timestamp) <=16, 1,0) AS  PMWORK, DATEPART(WEEK,se.create_timestamp) AS WeekPeriod



FROM [10.183.0.94].NGProd.dbo.[sig_events] se

WHERE se.modified_by IN (321,323,791,320,1049,600,1296,1334,1401,313,316)  AND CAST(se.modify_timestamp AS DATE) >= CAST('20150601' AS DATE) AND CAST(se.modify_timestamp AS DATE) < CAST('20151001' AS DATE) )


--Sat = 7
--SUn =1
--Mon =2
--Tues =3
--WED =4
--Thu =5
--Fr=6
 --Ben -- 791   -M-th PM
  --Bruce -320  Tu-Fri AM off monday
  --Journey -1049  -- Friday off
  --Searls -600 Mon WED Fri AM
  --Bernstein -1296 Weds off
  --Elton -- 1334 -- Thu afternoon off
  --Oveson -- 1401  M T WAM and FR PM works
  --chen --313 Works Fridays and Weds AM
  --Furer -- 316


,
filter2 AS (SELECT * FROM filter1 WHERE

NOT( (modified_by =321 AND  ( DAYNUMBER  IN (3,4))) OR
(modified_by =321 AND  ( DAYNUMBER =3 AND (AMWORk=1 OR PMWORK=1))) OR
(modified_by =323 AND  ( DAYNUMBER IN (2,3,4,5)AND (AMWORk=1 OR PMWORK=1))) OR
(modified_by =791 AND  ( DAYNUMBER  IN (2,3,4,5) AND PMWORK=1)) OR
(modified_by =320 AND  ( DAYNUMBER  IN (3,4,5,6) AND AMWORK=1)) OR
(modified_by =1049 AND  ( DAYNUMBER  IN (2,3,4,5,6) AND (PMWORK=1 OR PMWORK=1))) OR
(modified_by =600 AND  ( DAYNUMBER  IN (2,4,6) AND (AMWORK=1))) OR
(modified_by =1296 AND  ( DAYNUMBER  IN (2,3,5,6) AND (AMWORK=1))) OR
(modified_by =1296 AND  ( DAYNUMBER  IN (2,3,5,6) AND (PMWORK=1))) OR
(modified_by =1334 AND  ( DAYNUMBER  IN (2,3,4,6) AND (AMWORK=1 OR PMWORK=1))) OR
(modified_by =1334 AND  ( DAYNUMBER  IN (5) AND (AMWORK=1 ))) OR
(modified_by =1401 AND  ( DAYNUMBER  IN (2,3,4) AND (AMWORK=1 ))) OR
(modified_by =1401 AND  ( DAYNUMBER  IN (2,3,6) AND (PMWORK=1 ))) OR
(modified_by =313 AND  ( DAYNUMBER  IN (2,6) AND (AMWORK=1 OR PMWORK=1 ))) OR
(modified_by =313 AND  ( DAYNUMBER  IN (4) AND (AMWORK=1  ))) OR
(modified_by =316 AND  ( DAYNUMBER  IN (2,3,4,5) AND (AMWORK=1 OR PMWORK=1 ) )))


)


,--SELECT * FROM filter2 WHERE modified_by = 1296 
 filter3 AS (
 
 SELECT CAST(se.create_timestamp AS DATE) AS DateAccessed,
       DayNumber,DayHour,se.WeekPeriod,
	   um.last_name +', '+ um.first_name AS fullname,
	   se.source1_id,
	   se.event_source_type,
	   se.source2_id,
	   se.create_timestamp,
	   se.modified_by,
	   se.created_by ,
       FIRST_VALUE( se.create_timestamp) OVER ( PARTITION BY se.created_by, CAST(se.create_timestamp AS DATE) ORDER BY se.created_by,se.create_timestamp )  AS First_log,
	   se.sig_msg,
	 

	   DATEDIFF(MINUTE, se.create_timestamp,  
	   LAG( se.create_timestamp,1) OVER ( PARTITION BY se.created_by, CAST(se.create_timestamp AS DATE) ORDER BY se.created_by,se.create_timestamp DESC )  ) AS SinceLast

	   
	   

  FROM filter2 se INNER JOIN [10.183.0.94].NGProd.dbo.user_mstr um on se.modified_by = um.user_id
  

  )
 ,
 filter4 AS (SELECT * FROM filter3 WHERE sincelast<90),



 filter5 AS (
  SELECT fullname, filter4.WeekPeriod,SUM(sincelast)/60 AS hoursperday2 FROM filter4 GROUP BY fullname,Weekperiod )

  SELECT fullname, AVG(hoursperday2) FROM filter5 GROUP BY fullname









 --Carla -- 321   -- Tu, W
 --Ben -- 791   -M-th PM
  --Bruce -320  Tu-Fri AM off monday
  --Journey -1049  -- Friday off
  --Searls -600 Mon WED Fri AM
  --Bernstein -1296 Weds off
  --Elton -- 1334 -- Thu afternoon off
  --Oveson -- 1401  M T WAM and FR PM works
  --chen --313 Works Fridays and Weds AM
  --Furer -- 316

END
GO
