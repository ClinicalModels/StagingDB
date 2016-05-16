SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [prj].[patientServices_1511_Eligibility]
	-- Add the parameters for the stored procedure here
AS
BEGIN

   
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	--UPDATE dbo.staging_ng_eligibility_files_data
 --   SET txt_sourcefile=txt_sourcefile+'01'

-- delete same year data and keeps recent one 
--	 WITH recentYear AS(
--    SELECT txt_membid,txt_sourcefile, ROW_NUMBER() OVER (PARTITION BY txt_membid,SUBSTRING(txt_sourcefile,1,4) ORDER BY txt_sourcefile DESC ) AS rn1
--	FROM dbo.staging_ng_eligibility_files_data
--	)
	
--DELETE FROM recentYear WHERE recentYear.rn1>1



--Delete dublicate patient in the data by uniqe patid



--WITH    numbered
--          AS ( SELECT   patid,firstnm,lastnm
--                      , row_number() OVER ( PARTITION BY patid ORDER BY patid ) AS nr
--               FROM    [proto_mart].[dbo].[mgd_care_roster]
--             )
--   DELETE FROM numbered
--    WHERE   nr > 1


DECLARE @totalUniqueMember INT 
DECLARE @totalColumns int
DECLARE @currentMemberId VARCHAR(20)
DECLARE @currentColumnValue NVARCHAR(200)
DECLARE @i INT
DECLARE @sqlText NVARCHAR(500)
DECLARE @latestSourceFileYear NVARCHAR(20)

SELECT DISTINCT txt_membid INTO #TempMemberIdTable FROM dbo.staging_ng_eligibility_files_data


SET @totalUniqueMember= (SELECT COUNT(DISTINCT txt_membid) FROM  #TempMemberIdTable)
SET @totalColumns= (SELECT COUNT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_catalog ='Staging_Ghost' AND TABLE_SCHEMA = 'dbo' and TABLE_NAME='staging_ng_eligibility_files_data')
PRINT N'TotalColumnName'+CAST(@totalColumns AS NVARCHAR(20))
	
SET @i=1
IF @totalUniqueMember>1
	BEGIN
	  WHILE(@i<=@totalUniqueMember)
	  BEGIN 
		 DECLARE @k INT 
		 SELECT COLUMN_NAME INTO #columnsName FROM INFORMATION_SCHEMA.COLUMNS WHERE table_catalog ='Staging_Ghost' AND TABLE_SCHEMA = 'dbo' and TABLE_NAME='staging_ng_eligibility_files_data'
         DELETE FROM #columnsName WHERE COLUMN_NAME='txt_membid' or COLUMN_NAME='txt_sourcefile' or COLUMN_NAME='seq_no' 
		 SET @currentMemberId=(SELECT TOP 1 txt_membid FROM #TempMemberIdTable)
		
	     SET @latestSourceFileYear=(SELECT TOP 1 txt_sourcefile FROM dbo.staging_ng_eligibility_files_data WHERE txt_membid=@currentMemberId ORDER BY txt_sourcefile DESC)
		 DECLARE  @rowCountByMemberId INT
	     SET @rowCountByMemberId=((SELECT COUNT(txt_membid) FROM dbo.staging_ng_eligibility_files_data WHERE txt_membid=@currentMemberId)-1) 	
		 SET @k=1
		 IF(@rowCountByMemberId>0)
			BEGIN
			    PRINT N'Member ID :'+@currentMemberId
				WHILE (@k<=(@totalColumns-3))
					BEGIN
						DECLARE @currentColumnName NVARCHAR(20)
						DECLARE @currentCalumnValueTable TABLE (Value VARCHAR (100))
						SET @currentColumnName=(SELECT TOP 1 COLUMN_NAME FROM #columnsName)
						PRINT N'CurrentColumnName:  '+@currentColumnName
						PRINT N'NumberOfColumn   :  '+CAST(@k AS NVARCHAR(20) )
						PRINT N' CurrentMember   :  '+CAST(@i AS NVARCHAR(20))
						PRINT N'TotalMember      : '+CAST(@totalUniqueMember AS NVARCHAR(20))
						PRINT N'RowMembers       :  '+CAST(@rowCountByMemberId AS NVARCHAR(20))
						SET @sqlText=N' SELECT '+ @currentColumnName + 
						' FROM dbo.staging_ng_eligibility_files_data WHERE  txt_sourcefile='+@latestSourceFileYear+' and  txt_membid=  '+''''+@currentMemberId+''''
						INSERT INTO @currentCalumnValueTable
						EXEC sp_executesql @sqlText
						SET @currentColumnValue=(SELECT TOP 1 Value from @currentCalumnValueTable )
						PRINT N'CurrentColumnValue '+@currentColumnValue
						IF ((@currentColumnValue IS NULL) OR (@currentColumnValue='')) 
							BEGIN
								PRINT N'ColumnLookingNewValue----> '+@currentColumnName
								PRINT N'currentCalumnValue----> '+@currentColumnValue
								CREATE TABLE #leadValueTempTable (leadValue varchar(50))
								SET @sqlText=N'
								SELECT LEAD('+@currentColumnName+','+CAST(@rowCountByMemberId AS NVARCHAR(30))+')  OVER (ORDER BY '+ @currentColumnName+') AS leadValues
								FROM dbo.staging_ng_eligibility_files_data 	
								WHERE txt_membid='+''''+@currentMemberId+'''
								ORDER BY txt_sourcefile DESC ;'

								INSERT INTO #leadValueTempTable (leadValue)
								EXEC(@sqlText)
								DECLARE @newCalumnValue NVARCHAR(100)
								SET @newCalumnValue=(SELECT TOP 1 leadValue FROM #leadValueTempTable WHERE leadValue IS NOT NULL)
								PRINT N'New Calumn value --->'+@newCalumnValue
					            IF((@newCalumnValue IS NOT NULL) AND (@newCalumnValue<>''))
									BEGIN
										SET @sqlText= N'UPDATE dbo.staging_ng_eligibility_files_data
										SET '+@currentColumnName+'=(SELECT TOP 1 leadValue FROM #leadValueTempTable WHERE leadValue IS NOT NULL)
										WHERE txt_membid='+''''+@currentMemberId+'''	AND txt_sourcefile='+''''+@latestSourceFileYear+''''
										EXEC(@sqlText)
										PRINT N'New Value Updated'
									END
								DROP TABLE  #leadValueTempTable
							END
						DELETE from @currentCalumnValueTable
						DELETE FROM #columnsName WHERE COLUMN_NAME=@currentColumnName
						SET @k=@k+1
					END
			END
        DROP TABLE #columnsName 
		PRINT N'Deleting MemberID'+@currentMemberId
		DELETE FROM #TempMemberIdTable WHERE txt_membid=@currentMemberId
		SET @i=@i+1
		 --delete currentMemberId after update
	  END
    END
	DROP TABLE #TempMemberIdTable
END
GO
