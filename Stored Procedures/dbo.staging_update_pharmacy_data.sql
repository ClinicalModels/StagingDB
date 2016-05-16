SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[staging_update_pharmacy_data]
	
AS
BEGIN


declare @start_date  varchar(8), @end_date  varchar(8)

set @start_date = convert(char(8),dateadd(day,-1,getdate()),112) 
set @end_date = @start_date


delete 
from staging_ng_pharmacy_data_
WHERE start_date >= @start_date
  AND start_date <= @end_date



insert into dbo.staging_ng_pharmacy_data_ ([person_id] ,
	[location_id] ,
	[provider_id] ,
	[md_id] ,
	[enc_id] ,
	[rx_id] ,
	[gcnsecno] ,
	[drug_name] ,
	[ndc] ,
	[med_rec_nbr] ,
	[store_id] ,
	[start_date] ,
	[expire_date] ,
	[Provider_Name] ,
	[UserName],
	[RxNotbyProv] ,
	[PatName] ,
	[birth_date] ,
	[chart_id] ,
	[ssn] ,
	[sig_text], 
	[written_qty] ,
	[refills_left] ,
	[refills_orig] ,
	[SentTo] ,
	[clinic] ,
	[drug_dea_class] ,
	[operation_type] ,
	[mmyy] ,
	[Total_Non_Controlled] ,
	[Total_Controlled] ,
	[Sched_I] ,
	[Sched_II] ,
	[Sched_III] ,
	[Sched_IV] ,
	[Sched_V] 
)
SELECT DISTINCT p.person_id,
                lm.location_id,
                prov.provider_id,
                f.medid AS md_id,
                pm.enc_id,
                pm.medid AS rx_id,
                pm.gcn_seqno AS gcnsecno,
                pm.medication_name AS drug_name,
                pm.ndc_id AS ndc,
                p.med_rec_nbr ,
                erx.pharmacy_id AS store_id,
                (CASE
                     WHEN ISDATE (pm.start_date) = 1 THEN cast(pm.start_date AS date)
                 END) AS start_date,
                (CASE
                     WHEN ISDATE (pm.expiration_date) = 1 THEN cast(pm.expiration_date AS date)
                 END) AS expire_date,
                prov.description AS Provider_Name,
                um.last_name + ','+ um.first_name AS UserName,
                                    CASE
                                        WHEN prov.description LIKE ('%'+um.last_name+'%') THEN 0
                                        ELSE 1
                                    END RxNotbyProv ,
                                    per.last_name+', '+per.first_name AS PatName,
                                                       per.date_of_birth AS birth_date,
                                                       right(p.med_rec_nbr,6) AS chart_id,
                                                       per.ssn,
                                                       pm.sig_desc AS sig_text,
                                                       (CASE
                                                            WHEN isnumeric(pm.rx_quanity) = 1 THEN cast(Round(pm.rx_quanity,0) AS int)
                                                            ELSE 0
                                                        END) AS written_qty,
                                                       (CASE
                                                            WHEN isnumeric(pm.refills_left) = 1 THEN cast(Round(pm.refills_left,0) AS int)
                                                            ELSE 0
                                                        END) AS refills_left,
                                                       (CASE
                                                            WHEN isnumeric(pm.org_refills) = 1 THEN cast(Round(pm.org_refills,0) AS int)
                                                            ELSE 0
                                                        END) AS refills_orig,
                                                       pharma.name AS SentTo,
                                                       lm.location_name AS clinic,
                                                       f.med_ref_dea_class_code AS drug_dea_class,
                                                       CASE
                                                           WHEN pa.operation_type ='P' THEN 'Print'
                                                           WHEN pa.operation_type ='E' THEN 'eRx'
                                                           WHEN pa.operation_type ='F' THEN 'Fax'
                                                           WHEN pa.operation_type ='D' THEN 'DAP'
                                                       END operation_type ,
                                                       SUBSTRING(CONVERT(VARCHAR(8),convert(datetime, pm.start_date,101) ,3),4,5) AS mmyy,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code=0 THEN 1
                                                            ELSE 0
                                                        END)AS Total_Non_Controlled,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code<>0 THEN 1
                                                            ELSE 0
                                                        END) AS Total_Controlled,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code=1 THEN 1
                                                            ELSE 0
                                                        END) AS Sched_I,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code=2 THEN 1
                                                            ELSE 0
                                                        END) AS Sched_II,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code=3 THEN 1
                                                            ELSE 0
                                                        END) AS Sched_III,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code=4 THEN 1
                                                            ELSE 0
                                                        END) AS Sched_IV,
                                                       (CASE
                                                            WHEN f.med_ref_dea_class_code=5 THEN 1
                                                            ELSE 0
                                                        END) AS Sched_V 


FROM [10.183.0.94].[NGProd].[dbo].person per with(nolock)
INNER JOIN [10.183.0.94].[NGProd].[dbo].patient_medication pm with(nolock) ON per.person_id = pm.person_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].patient p with(nolock) ON p.person_id =per.person_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].provider_mstr prov with(nolock) ON pm.provider_id =prov.provider_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].location_mstr lm with(nolock) ON pm.location_id =lm.location_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].fdb_med_mstr f ON pm.medid =f.medid
AND pm.gcn_seqno =pm.gcn_seqno
INNER JOIN [10.183.0.94].[NGProd].[dbo].erx_message_history erx with(nolock) ON per.person_id =erx.person_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].med_rx_notes med with(nolock) ON erx.medication_id =med.medication_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].pharmacy_mstr pharma with(nolock) ON erx.pharmacy_id =pharma.pharmacy_id
INNER JOIN [10.183.0.94].[NGProd].[dbo].user_mstr um ON pm.created_by =um.user_id
LEFT OUTER JOIN [10.183.0.94].[NGProd].[dbo].prescription_audit pa with(nolock) ON pm.enc_id =pa.enc_id
WHERE pm.start_date >= @start_date  -- made need to modify this to capture that start date may be a future date for the prescription.
  AND pm.start_date <= @end_date
  AND pa.operation_type <>''

  AND   lm.location_id  IN (SELECT location_id FROM dbo.staging_ng_location_)
END
GO
