SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [prj].[patientServices_1512_eligibility_buildTables]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET ANSI_NULLS ON
	SET QUOTED_IDENTIFIER ON
	SET ANSI_PADDING ON


CREATE TABLE [dbo].[staging_ng_eligibility_files_data](
	[seq_no] INT IDENTITY NOT NULL,
	[txt_chc] [varchar](255) NULL,
	[txt_company] [varchar](255) NULL,
	[txt_effdate] [varchar](255) NULL,
	[txt_termdate] [varchar](255) NULL,
	[txt_patid] [varchar](255) NULL,
	[txt_plan] [varchar](255) NULL,
	[txt_subssn] [varchar](255) NULL,
	[txt_lastnm] [varchar](255) NULL,
	[txt_firstnm] [varchar](255) NULL,
	[txt_street] [varchar](255) NULL,
	[txt_city] [varchar](255) NULL,
	[txt_zip] [varchar](255) NULL,
	[txt_dob] [varchar](255) NULL,
	[txt_sex] [varchar](255) NULL,
	[txt_phone] [varchar](255) NULL,
	[txt_language] [varchar](255) NULL,
	[txt_mcal10] [varchar](255) NULL,
	[txt_otherid2] [varchar](255) NULL,
	[txt_site] [varchar](255) NULL,
	[txt_membid] [varchar](255) NULL,
	[txt_hic] [varchar](255) NULL,
	[txt_mcarea] [varchar](255) NULL,
	[txt_mcareb] [varchar](255) NULL,
	[txt_ccs] [varchar](255) NULL,
	[txt_ccsdt] [varchar](255) NULL,
	[txt_cob] [varchar](255) NULL,
	[txt_hfpcopay] [varchar](255) NULL,
	[txt_ac] [varchar](255) NULL,
	[txt_transactionCode] [VARCHAR](255) NULL,
	[txt_transactionDate][VARCHAR](255) NULL,
	[txt_sourcefile] [varchar](255) NULL

	
PRIMARY KEY CLUSTERED 
(
	[seq_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[staging_ng_eligibility_final_data](
	[First_mon_date] [DATE] NOT NULL, 
	[txt_membid] [varchar](255) NULL,
	[txt_chc] [varchar](255) NULL,
	[txt_company] [varchar](255) NULL,
	[txt_effdate] [varchar](255) NULL,
	[txt_termdate] [varchar](255) NULL,
	[txt_patid] [varchar](255) NULL,
	[txt_plan] [varchar](255) NULL,
	[txt_subssn] [varchar](255) NULL,
	[txt_lastnm] [varchar](255) NULL,
	[txt_firstnm] [varchar](255) NULL,
	[txt_street] [varchar](255) NULL,
	[txt_city] [varchar](255) NULL,
	[txt_zip] [varchar](255) NULL,
	[txt_dob] [varchar](255) NULL,
	[txt_sex] [varchar](255) NULL,
	[txt_phone] [varchar](255) NULL,
	[txt_language] [varchar](255) NULL,
	[txt_mcal10] [varchar](255) NULL,
	[txt_otherid2] [varchar](255) NULL,
	[txt_site] [varchar](255) NULL,
	[txt_hic] [varchar](255) NULL,
	[txt_mcarea] [varchar](255) NULL,
	[txt_mcareb] [varchar](255) NULL,
	[txt_ccs] [varchar](255) NULL,
	[txt_ccsdt] [varchar](255) NULL,
	[txt_cob] [varchar](255) NULL,
	[txt_hfpcopay] [varchar](255) NULL,
	[txt_ac] [varchar](255) NULL,
	[txt_transactionCode] [VARCHAR](255) NULL,
	[txt_transactionDate][VARCHAR](255) NULL
	
	)



SET ANSI_PADDING OFF


    
END
GO
