SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[update_data_location_ecw]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('dbo.data_location_ecw') IS NOT NULL 
		DROP TABLE dbo.data_location_ecw

	IF OBJECT_ID('tempdb..#loc_temp') IS NOT NULL
		DROP TABLE #loc_temp

SELECT * INTO #loc_temp
FROM OPENQUERY(ECWDB,'
	SELECT 
		Id
      ,Name,
	   code
	  ,facilitynickname
      ,portal_name
      ,AddressLine1
      ,City
      ,State
      ,Zip
      ,Tel
      ,Fax
      ,BillingAddressLine1
	  ,BillingAddressLine2
      ,BillingCity
      ,BillingState
      ,BillingZip
      ,BillingTel
      ,BillingFax,
	  FacilityType,
	  date_format(startedOn, ''%Y-%m-%d %T'') AS location_start_date
FROM mobiledoc.edi_facilities')

SELECT
	IDENTITY(INT,1,1) AS ecw_location_key
		,[Id] AS location_id
      ,[Name]
      ,[code]
      ,[facilitynickname]
      ,[portal_name]
      ,[AddressLine1]
      ,[City]
      ,[State]
      ,[Zip]
      ,[Tel]
      ,[Fax]
      ,[BillingAddressLine1]
      ,[BillingAddressLine2]
      ,[BillingCity]
      ,[BillingState]
      ,[BillingZip]
      ,[BillingTel]
      ,[BillingFax]
      ,[FacilityType]
      ,CONVERT(datetime, location_start_date) AS location_start_date
INTO dbo.data_location_ecw
FROM #loc_temp 


END
GO
