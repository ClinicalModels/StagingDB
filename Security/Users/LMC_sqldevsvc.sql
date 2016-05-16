IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'LMC\sqldevsvc')
CREATE LOGIN [LMC\sqldevsvc] FROM WINDOWS
GO
CREATE USER [LMC\sqldevsvc] FOR LOGIN [LMC\sqldevsvc]
GO
