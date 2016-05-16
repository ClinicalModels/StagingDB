SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Staging_tool_OLEDB_convert] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--sp_configure 'Show Advanced Options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO
--EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 0
--GO

--iF YOU GET AN ERROR AND THE TXT OR EXCEL FILE db will not initialize, change the AllowinProcess from 0 to 1 or vice versa -- this seems to get it working again


--EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
--GO





SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
  'Excel 12.0;Database=C:\temp\MedicareCallList.xlsx', [Sheet1$])








  /*
  --#################################################################################################
 --Linked server Syntax for Folder Full Of Text Files -- Also settings for delimited txt file
 --#################################################################################################
 
 --add a folder as a linked server to access all .txt and .csv files in the folder
 DECLARE @server     sysname,
				 @srvproduct nvarchar(256),
				 @provider   nvarchar(256),
				 @datasrc    nvarchar(100),
				 @location   nvarchar(100),
				 @provstr    nvarchar(100),
				 @catalog    sysname,
				 @sql        varchar(1000)
 SET @server = N'TxtSvr'
 SET @srvproduct = N'OLE DB Provider for ACE'
 SET @provider = N'Microsoft.ACE.OLEDB.12.0'
 SET @datasrc = N'C:\temp\'
 SET @provstr ='Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\temp\;Extended Properties="text;HDR=YES;FMT=Delimited" '
 set @provstr  = 'Text'
 
 EXEC  sp_addlinkedserver  @server,@srvproduct,@provider,@datasrc,@provstr,@provstr
 --===== Create a linked server to the drive and path you desire.
		--EXEC dbo.sp_AddLinkedServer TxtSvr, 
		--     'MSDASQL', 
		--     'Microsoft.ACE.OLEDB.12.0',
		--     'C:\',
		--     NULL,
		--     'Text'
 GO
 --===== Set up login mappings.
 EXEC dbo.sp_AddLinkedSrvLogin TxtSvr, FALSE, NULL, Admin, NULL
 GO
 --===== List the tables in the linked server which is really a list of 
			-- file names in the directory.  Note that the "#" sign in the
			-- Table_Name is where the period in the filename actually goes.
		EXEC dbo.sp_Tables_Ex TxtSvr
 GO
 --===== Query one of the files by using a four-part name. 
 SELECT * 
		FROM TxtSvr...[LEgalName_NickName_List#txt]
 
 --===== Drop the text server
   EXEC dbo.sp_DropServer 'TxtSvr', 'DropLogins'
 GO
*/

 












END
GO
