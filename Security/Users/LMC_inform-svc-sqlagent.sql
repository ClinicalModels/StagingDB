IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'LMC\inform-svc-sqlagent')
CREATE LOGIN [LMC\inform-svc-sqlagent] FROM WINDOWS
GO
CREATE USER [LMC\inform-svc-sqlagent] FOR LOGIN [LMC\inform-svc-sqlagent]
GO
