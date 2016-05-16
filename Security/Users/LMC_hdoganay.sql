IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'LMC\hdoganay')
CREATE LOGIN [LMC\hdoganay] FROM WINDOWS
GO
CREATE USER [LMC\hdoganay] FOR LOGIN [LMC\hdoganay]
GO
