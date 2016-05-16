SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Staging_util_create_linked_server]
AS
BEGIN
DECLARE @test int


/*

--FOR MTS environment at CHCN

-- In order to use a linked server you need to have a SQL local login account.  Double hop fails for authenication.
-- see this http://blogs.msdn.com/b/sql_protocols/archive/2006/08/10/694657.aspx
--The main thing about this article is that to use windows authenitication you've got to create trusted relationships between the servers.
-- I didn't have domain privildges so I could not do it.

-- The configuration mapping that was successful for me was:
	EXEC sp_addlinkedserver 
	@server = '10.183.0.64'	-- local name of the linked server to create.
					-- If data_source is not specified, server is the actual name of the instance
	,@srvproduct = 'SQL Server'


EXEC sp_addlinkedsrvlogin @rmtsrvname = '10.183.0.64'
,	@useself = 'false'	-- true=Connect using current UserID/Password, false=use rmtuser/rmtpassword below
,	@locallogin = NULL	-- NULL=All local logins use this remote login account, otherwise local login UserName being set up (repeat for each one required)
-- Execute ONLY to here IF @UseSelf='TRUE' (above)
,	@rmtuser = 'bmansalis_local'	-- Note this account does not use a DOMAIN level authentication.  UserName on Remote corresponding to this @LocalLogin.   
,	@rmtpassword = 'Password'	-- Ditto password
--,   @provstr='Integrated Security=SSPI;'



-- Create a Linked Server
-- Use this script to create a linked server

-- Globally change the following:

-- Remote server name: MyRemoteServer
--  Server name can be any name resolved by DNS, e.g. a name like SERVERNAME.HOSTS.MYDomain.COM
--  or even IP address in the format 123.456.789.123)
--  Do **NOT** include [ ] - so SERVERNAME.HOSTS.MYDomain.COM is fine as a name wihtout quotes/brackets
-- IP Address: 111.222.333.444 (only used if MyRemoteServer name does not work)

-- SQL Port: 1144	-- Change if using a non-standard port and use the SPECIAL sp_addlinkedserver command below

-- User Login: MyUserID
-- User Password: MyPassword
-- (This should be a database login available on both machines with the same password)

-- *** Having done Find&Replace of parameters (above), highlight each section (below) and execute

-- Create a linked server:
USE master
GO

-- Show linked servers
EXEC sp_linkedservers


-- EXEC sp_helpserver			-- (Also shows services etc.

-- Delete any existing linked-server attempt (optional)
EXEC sp_dropserver 
	@server = 'MyRemoteServer', 
	@droplogins = 'droplogins'		-- 'droplogins' = Drop associated logins, NULL=Do not drop logins


-- Create Linked Server (use command below for NON-Standard port
EXEC sp_addlinkedserver 
	@server = 'MyRemoteServer'		-- local name of the linked server to create.
					-- If data_source is not specified, server is the actual name of the instance
,	@srvproduct = 'SQL Server'	-- product name of the OLE DB data source to add as a linked server
					-- If "SQL Server", provider_name, data_source, location, provider_string, and catalog do not need to be specified.
-- Following are needed for connections to NON SQL servers
-- 	,@provider = 'SQLOLEDB'		-- unique programmatic identifier of the OLE DB provider (PROGID) 
-- 	,@datasrc = 'MyRemoteServer'	-- name of the data source as interpreted by the OLE DB provider (DBPROP_INIT_DATASOURCE property)

-- For NON-Standard SQL Port use:
-- EXEC sp_addlinkedserver @server = 'MyRemoteServer', @srvproduct = 'SQL Server', @provider = 'SQLOLEDB', @datasrc = 'MyRemoteServer,1144'	-- Set the port appropriately
-- Example of Oracle connection:
-- EXEC sp_addlinkedserver @server = 'MyOracleServer', @srvproduct = 'Oracle', @provider = 'MSDAORA', @datasrc = 'OracleServerName'	-- , @location=NULL, @provstr=NULL, @catalog=NULL

-- Remove existing Linked Server Login (optional)
EXEC sp_droplinkedsrvlogin @rmtsrvname = 'MyRemoteServer'
,	@locallogin = 'MyUserID'


-- Create Linked Server Login
EXEC sp_addlinkedsrvlogin @rmtsrvname = 'MyRemoteServer' 
,	@useself = 'false'	-- true=Connect using current UserID/Password, false=use rmtuser/rmtpassword below
,	@locallogin = 'MyUserID'	-- NULL=All local logins use this remote login account, otherwise local login UserName being set up (repeat for each one required)
-- Execute ONLY to here IF @UseSelf='TRUE' (above)
,	@rmtuser = 'MyUserID'	-- UserName on Remote corresponding to this @LocalLogin.   
,	@rmtpassword = 'MyPassword'	-- Ditto password

-- Test connection - should list databases on remote machine
select top 10 name from [MyRemoteServer].master.dbo.sysdatabases

-- If you get this error message:
-- "Server '111.222.333.444' is not configured for DATA ACCESS"
-- then execute this statement
exec sp_serveroption 'MyRemoteServer', 'data access', 'true'

-- exec sp_serveroption @server='MyRemoteServer', @optname='rpc out', @optvalue=true

-- Test again!
select top 10 name from [MyRemoteServer].master.dbo.sysdatabases

-- Alternative test using OPENQUERY
SELECT	*
FROM	OPENQUERY([MyRemoteServer], 'SELECT TOP 10 * FROM master.dbo.sysobjects') 
GO

-- Failing that try to PING the remote server (by Extended Procedure Command line call)
-- if that fails then your SQL box cannot see the remote server

exec master.dbo.xp_cmdshell 'PING 111.222.333.444'
*/


END
GO
