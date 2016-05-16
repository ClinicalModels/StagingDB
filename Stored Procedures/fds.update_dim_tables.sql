SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fds].[update_dim_tables]
AS
    BEGIN

        SET NOCOUNT ON;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        IF OBJECT_ID('fds.dim_medication') IS NOT NULL
            DROP TABLE fds.dim_medication;


        IF OBJECT_ID('fds.dim_pharmacy') IS NOT NULL
            DROP TABLE fds.dim_pharmacy;

        IF OBJECT_ID('fds.dim_validation') IS NOT NULL
            DROP TABLE fds.dim_validation;
			
			    IF OBJECT_ID('fds.dim_cpt4') IS NOT NULL
            DROP TABLE [Staging_Ghost].fds.dim_cpt4;

			
			    IF OBJECT_ID('fds.dim_service_item') IS NOT NULL
            DROP TABLE [Staging_Ghost].fds.dim_service_item;
			    IF OBJECT_ID('fds.dim_encounter_status') IS NOT NULL
            DROP TABLE [Staging_Ghost].fds.dim_encounter_status;

			    IF OBJECT_ID('fds.dim_time') IS NOT NULL
            DROP TABLE [Staging_Ghost].fds.dim_time;

	

        SELECT  [ndc_id] ,
                COALESCE([gcn_seqno], -1) AS gcn_seqno ,
                COALESCE([hicl_seqno], '') AS [hicl_seqno] ,
                COALESCE([medid], -1) AS medid ,
                COALESCE([gcn], -1) AS gcn ,
                COALESCE([brand_name], '') AS brand_name ,
                COALESCE([generic_name], '') AS generic_name ,
                COALESCE([dose], '') AS dose ,
                COALESCE([dose_form_desc], '') AS dose_form_desc ,
                COALESCE([route_desc], '') AS route_desc ,
                COALESCE([med_cat_class_desc], '') AS med_class ,
                COALESCE([dea_id], '') AS med_sched ,
                COALESCE([generic_indicator], '') AS gen_ind ,
                COALESCE([delete_ind], '') AS del_ind
        INTO    fds.dim_medication
        FROM    [10.183.0.94].[NGProd].[dbo].[fdb_medication];

		
        SELECT  [pharmacy_id] ,
                COALESCE([name], '') AS Name ,
                COALESCE([address_line_1], '') AS Address1 ,
                COALESCE([address_line_2], '') AS address2 ,
                COALESCE([city], '') AS city ,
                COALESCE([state], '') AS state ,
                COALESCE([zip], '') AS zipcode ,
                COALESCE([phone], '') AS phone ,
                COALESCE([fax], '') AS fax ,
                COALESCE([delete_ind], '') AS deleted_ind ,
                COALESCE([store_number], '') AS store_number ,
                COALESCE([active_erx_ind], '') AS accept_erx ,
                COALESCE([mail_order_ind], '') AS accept_rx_mail_order ,
                COALESCE(rx_by_fax_ind, '') AS accept_rx_fax
        INTO    fds.dim_pharmacy
        FROM    [10.183.0.94].[NGProd].[dbo].[pharmacy_mstr]; 


	 
	 
	 
	--  [operation_type] ,  -- will need to merge this back on to pharmacy as extra attribute
               
	 


        SELECT  enc.enc_id ,
                COALESCE(enc.enc_nbr, -1) AS enc_number ,
                COALESCE(loc.location_name, '') AS location_name ,
                COALESCE(prov.provider_name, '') AS provider_name ,
                COALESCE(per.full_Name, '') AS patient_name ,
                COALESCE(per.med_rec_nbr, '') AS med_rec_nbr ,
                enc.enc_bill_date ,
                CASE WHEN COALESCE(enc.billable_enc_ct, -1) = 1 THEN 'Yes'
                     ELSE 'No'
                END AS billable_encounter ,
                CASE WHEN COALESCE(enc.qual_enc_ct, -1) = 1 THEN 'Yes'
                     ELSE 'No'
                END AS Qualified_encounter
        INTO    fds.dim_validation
        FROM    dwh.data_encounter enc
                LEFT JOIN dwh.data_person per ON per.person_id = enc.person_id
                LEFT JOIN dwh.data_location loc ON loc.location_id = enc.location_id
                INNER JOIN dwh.data_provider prov ON enc.provider_id = prov.provider_id; 

	   
	   
      
        SELECT  [cpt4_code_id] ,
                ( FLOOR(RANK() OVER ( ORDER BY cpt4_code_id ) / 1000) + 1 ) AS CPT_Group ,
                [description] ,
                [type_of_service]
        INTO    [Staging_Ghost].fds.dim_cpt4
        FROM    [10.183.0.94].[NGProd].[dbo].[cpt4_code_mstr]; 

	


SELECT  service_item_id ,
        ( FLOOR(RANK() OVER ( ORDER BY service_item_id ) / 1000) + 1 ) AS Service_Item_Group ,
        eff_date ,
        exp_date ,
        COALESCE(description, '') AS description ,
        cpt4_code_id ,
        current_price,
        COALESCE(revenue_code, '') AS revenue_code ,
        COALESCE(form, '') AS form ,
        COALESCE(rental_duration_per_unit, '') AS rental_duration_per_unit ,
        COALESCE(unassigned_benefit, 0) AS unassigned_benefit ,
        COALESCE(unassigned_benefit_fac, 0) AS unassigned_benefit_fac ,
        rental_ind,
        behavioral_billing_ind,
        self_pay_fqhc_ind,
        sliding_fee_fqhc_ind,
        clinic_rate_exempt_ind,
        sliding_fee_exempt_ind,
        fqhc_enc_ind,
        delete_ind
INTO    fds.dim_service_item
FROM    [10.183.0.94].NGProd.dbo.service_item_mstr;

SELECT   ROW_NUMBER() OVER ( ORDER BY enc_status, billable_enc_ct, qual_enc_ct ) AS EncStatusKey ,
                                x1.enc_status ,
                                x2.billable_enc_ct ,
                                x3.qual_enc_ct ,
                                CASE WHEN enc_status = 'U' THEN 'Unbilled'
                                     WHEN enc_status = 'R' THEN 'Rebilled'
                                     WHEN enc_status = 'H' THEN 'History'
                                     WHEN enc_status = 'B' THEN 'Billed'
                                     WHEN enc_status = 'D' THEN 'Bad Debt'
                                     ELSE 'Unknown'
                                END AS Encounter_status ,
                                CASE WHEN [billable_enc_ct] = 1 THEN 'Billable'
                                     ELSE 'Not Billable'
                                END AS Billable_ind ,
                                CASE WHEN [qual_enc_ct] = 1 THEN 'Qualified'
                                     ELSE 'Not Qualified'
                                END AS Qual_ind
                       
					   INTO fds.dim_encounter_status
					   FROM     ( SELECT DISTINCT
                                            enc_status
                                  FROM      [Staging_Ghost].[dwh].data_encounter
                                ) x1
                                CROSS JOIN ( SELECT DISTINCT
                                                    billable_enc_ct
                                             FROM    [Staging_Ghost].[dwh].data_encounter
                                           ) x2
                                CROSS JOIN ( SELECT DISTINCT
                                                    qual_enc_ct
                                             FROM   [Staging_Ghost].[dwh].data_encounter
                                           ) x3
                     



SELECT * INTO fds.dim_time FROM dwh.data_time


    END;
GO
