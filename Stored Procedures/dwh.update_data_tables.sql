SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dwh].[update_data_tables]

AS
BEGIN
exec dwh.update_data_person_month
exec dwh.update_data_person
exec dwh.update_data_prov_user_loc
EXEC dwh.update_data_time
EXEC dwh.update_data_diagnosis
exec dwh.update_data_encounter
exec dwh.update_data_charge
exec dwh.update_data_transaction
exec dwh.update_data_pharmacy
exec dwh.update_data_appointment

END
GO
