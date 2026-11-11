-- Dashboard   : "Internal Users Search Adrian"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Internal Users Search Adrian" (embedded in the workbook)
-- Relation    : Custom SQL "HR data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH second_level_managers
AS (
	SELECT DISTINCT CONCAT (
			last_name
			,','
			,first_name
			) AS reporting_employee_name
		,Manager_Name AS first_level_manager
		,NULL AS second_level_manager
		,NULL AS third_level_manager
		,NULL AS fourth_level_manager
		,NULL AS fifth_level_manager
		,NULL AS sixth_level_manager
		,NULL AS seventh_level_manager
		,dj_employee_id AS reporting_employee_id
	FROM dimension_external_db.workday_employee_current
	WHERE Manager_Name LIKE '%Almar%'
	)
	,third_level_managers
AS (
	SELECT tl.reporting_employee_name
		,tl.first_level_manager
		,tl.second_level_manager
		,tl.third_level_manager
		,tl.fourth_level_manager
		,tl.fifth_level_manager
		,tl.sixth_level_manager
		,tl.seventh_level_manager
		,tl.reporting_employee_id
	FROM (
		SELECT TEMP.*
			,row_number() OVER (
				PARTITION BY TEMP.reporting_employee_name ORDER BY (
						CASE 
							WHEN TEMP.is_manager = true
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_id LIKE 'dj%'
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_name = TEMP.legal_name
								THEN 1
							ELSE 0
							END
						) DESC
				) rn
		FROM (
			SELECT CONCAT (
					third_level.last_name
					,','
					,third_level.first_name
					) AS reporting_employee_name
				,second_level_managers.first_level_manager
				,third_level.Manager_Name AS second_level_manager
				,NULL AS third_level_manager
				,NULL AS fourth_level_manager
				,NULL AS fifth_level_manager
				,NULL AS sixth_level_manager
				,NULL AS seventh_level_manager
				,third_level.dj_employee_id AS reporting_employee_id
				,third_level.is_manager
				,third_level.legal_name
			FROM second_level_managers
			JOIN dimension_external_db.workday_employee_current third_level ON second_level_managers.reporting_employee_name = third_level.Manager_Name
			) TEMP
		) tl
	WHERE tl.rn = 1
	)
	,fourth_level_managers
AS (
	SELECT fl.reporting_employee_name
		,fl.first_level_manager
		,fl.second_level_manager
		,fl.third_level_manager
		,fl.fourth_level_manager
		,fl.fifth_level_manager
		,fl.sixth_level_manager
		,fl.seventh_level_manager
		,fl.reporting_employee_id
	FROM (
		SELECT TEMP.*
			,row_number() OVER (
				PARTITION BY TEMP.reporting_employee_name ORDER BY (
						CASE 
							WHEN TEMP.is_manager = true
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_id LIKE 'dj%'
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_name = TEMP.legal_name
								THEN 1
							ELSE 0
							END
						) DESC
				) rn
		FROM (
			SELECT CONCAT (
					fourth_level.last_name
					,','
					,fourth_level.first_name
					) AS reporting_employee_name
				,third_level_managers.first_level_manager
				,third_level_managers.second_level_manager
				,fourth_level.Manager_Name AS third_level_manager
				,NULL AS fourth_level_manager
				,NULL AS fifth_level_manager
				,NULL AS sixth_level_manager
				,NULL AS seventh_level_manager
				,fourth_level.dj_employee_id AS reporting_employee_id
				,fourth_level.is_manager
				,fourth_level.legal_name
			FROM third_level_managers
			JOIN dimension_external_db.workday_employee_current fourth_level ON third_level_managers.reporting_employee_name = fourth_level.Manager_Name
			) TEMP
		) fl
	WHERE fl.rn = 1
	)
	,fifth_level_managers
AS (
	SELECT fil.reporting_employee_name
		,fil.first_level_manager
		,fil.second_level_manager
		,fil.third_level_manager
		,fil.fourth_level_manager
		,fil.fifth_level_manager
		,fil.sixth_level_manager
		,fil.seventh_level_manager
		,fil.reporting_employee_id
	FROM (
		SELECT TEMP.*
			,row_number() OVER (
				PARTITION BY TEMP.reporting_employee_name ORDER BY (
						CASE 
							WHEN TEMP.is_manager = true
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_id LIKE 'dj%'
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_name = TEMP.legal_name
								THEN 1
							ELSE 0
							END
						) DESC
				) rn
		FROM (
			SELECT CONCAT (
					fifth_level.last_name
					,','
					,fifth_level.first_name
					) AS reporting_employee_name
				,fourth_level_managers.first_level_manager
				,fourth_level_managers.second_level_manager
				,fourth_level_managers.third_level_manager
				,fifth_level.Manager_Name AS fourth_level_manager
				,NULL AS fifth_level_manager
				,NULL AS sixth_level_manager
				,NULL AS seventh_level_manager
				,fifth_level.dj_employee_id AS reporting_employee_id
				,fifth_level.is_manager
				,fifth_level.legal_name
			FROM fourth_level_managers
			JOIN dimension_external_db.workday_employee_current fifth_level ON fourth_level_managers.reporting_employee_name = fifth_level.Manager_Name
			) TEMP
		) fil
	WHERE fil.rn = 1
	)
	,sixth_level_managers
AS (
	SELECT sil.reporting_employee_name
		,sil.first_level_manager
		,sil.second_level_manager
		,sil.third_level_manager
		,sil.fourth_level_manager
		,sil.fifth_level_manager
		,sil.sixth_level_manager
		,sil.seventh_level_manager
		,sil.reporting_employee_id
	FROM (
		SELECT TEMP.*
			,row_number() OVER (
				PARTITION BY TEMP.reporting_employee_name ORDER BY (
						CASE 
							WHEN TEMP.is_manager = true
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_id LIKE 'dj%'
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_name = TEMP.legal_name
								THEN 1
							ELSE 0
							END
						) DESC
				) rn
		FROM (
			SELECT CONCAT (
					sixth_level.last_name
					,','
					,sixth_level.first_name
					) AS reporting_employee_name
				,fifth_level_managers.first_level_manager
				,fifth_level_managers.second_level_manager
				,fifth_level_managers.third_level_manager
				,fifth_level_managers.fourth_level_manager
				,sixth_level.Manager_Name AS fifth_level_manager
				,NULL AS sixth_level_manager
				,NULL AS seventh_level_manager
				,sixth_level.dj_employee_id AS reporting_employee_id
				,sixth_level.is_manager
				,sixth_level.legal_name
			FROM fifth_level_managers
			JOIN dimension_external_db.workday_employee_current sixth_level ON fifth_level_managers.reporting_employee_name = sixth_level.Manager_Name
			) TEMP
		) sil
	WHERE sil.rn = 1
	)
	,seventh_level_managers
AS (
	SELECT sel.reporting_employee_name
		,sel.first_level_manager
		,sel.second_level_manager
		,sel.third_level_manager
		,sel.fourth_level_manager
		,sel.fifth_level_manager
		,sel.sixth_level_manager
		,sel.seventh_level_manager
		,sel.reporting_employee_id
	FROM (
		SELECT TEMP.*
			,row_number() OVER (
				PARTITION BY TEMP.reporting_employee_name ORDER BY (
						CASE 
							WHEN TEMP.is_manager = false
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_id LIKE 'dj%'
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_name = TEMP.legal_name
								THEN 1
							ELSE 0
							END
						) DESC
				) rn
		FROM (
			SELECT CONCAT (
					seventh_level.last_name
					,','
					,seventh_level.first_name
					) AS reporting_employee_name
				,sixth_level_managers.first_level_manager
				,sixth_level_managers.second_level_manager
				,sixth_level_managers.third_level_manager
				,sixth_level_managers.fourth_level_manager
				,sixth_level_managers.fifth_level_manager
				,seventh_level.Manager_Name AS sixth_level_manager
				,NULL AS seventh_level_manager
				,seventh_level.dj_employee_id AS reporting_employee_id
				,seventh_level.is_manager
				,seventh_level.legal_name
			FROM sixth_level_managers
			JOIN dimension_external_db.workday_employee_current seventh_level ON sixth_level_managers.reporting_employee_name = seventh_level.Manager_Name
			) TEMP
		) sel
	WHERE sel.rn = 1
	)
	,eighth_level_managers
AS (
	SELECT el.reporting_employee_name
		,el.first_level_manager
		,el.second_level_manager
		,el.third_level_manager
		,el.fourth_level_manager
		,el.fifth_level_manager
		,el.sixth_level_manager
		,el.seventh_level_manager
		,el.reporting_employee_id
	FROM (
		SELECT TEMP.*
			,row_number() OVER (
				PARTITION BY TEMP.reporting_employee_name ORDER BY (
						CASE 
							WHEN TEMP.is_manager = false
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_id LIKE 'dj%'
								THEN 1
							ELSE 0
							END
						) DESC
					,(
						CASE 
							WHEN TEMP.reporting_employee_name = TEMP.legal_name
								THEN 1
							ELSE 0
							END
						) DESC
				) rn
		FROM (
			SELECT CONCAT (
					eighth_level.last_name
					,','
					,eighth_level.first_name
					) AS reporting_employee_name
				,seventh_level_managers.first_level_manager
				,seventh_level_managers.second_level_manager
				,seventh_level_managers.third_level_manager
				,seventh_level_managers.fourth_level_manager
				,seventh_level_managers.fifth_level_manager
				,seventh_level_managers.sixth_level_manager
				,eighth_level.Manager_Name AS seventh_level_manager
				,eighth_level.dj_employee_id AS reporting_employee_id
				,eighth_level.is_manager
				,eighth_level.legal_name
			FROM seventh_level_managers
			JOIN dimension_external_db.workday_employee_current eighth_level ON seventh_level_managers.reporting_employee_name = eighth_level.Manager_Name
			) TEMP
		) el
	WHERE el.rn = 1
	)
	,Emp_hierarchy
AS (
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM second_level_managers
	
	UNION ALL
	
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM third_level_managers
	
	UNION ALL
	
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM fourth_level_managers
	
	UNION ALL
	
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM fifth_level_managers
	
	UNION ALL
	
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM sixth_level_managers
	
	UNION ALL
	
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM seventh_level_managers
	
	UNION ALL
	
	SELECT reporting_employee_name
		,first_level_manager
		,second_level_manager
		,third_level_manager
		,fourth_level_manager
		,fifth_level_manager
		,sixth_level_manager
		,seventh_level_manager
		,reporting_employee_id
	FROM eighth_level_managers
	)
SELECT reporting_employee_id
	,reporting_employee_name
	,first_level_manager
	,second_level_manager
	,third_level_manager
	,fourth_level_manager
	,fifth_level_manager
	,sixth_level_manager
	,seventh_level_manager,username,employee_category,
budget_location_addr1 
,budget_location_addr2,
budget_location_bldg_code,
budget_location_bldg_name,
budget_location_city_code,
budget_location_country_code,
budget_location_postal_code,
budget_location_region_code,
budget_location_state_code,
business_area_name,
business_cell_country_code,
business_cell_number,
business_phone_country_code,
business_phone_extension,
business_phone_number,
business_principal,
business_unit_code,
business_unit_name,
comp_planner_name,
company_code,
company_name,
department_name,
dj_employee_id,
email_address,
employee_class,
employee_class_description,
employee_status,
employee_type,
etl_processed_date,
first_name,
CONCAT(first_name, ' ', last_name) AS full_name,
floor_code,
floor_information,
hr_partner_name,
is_bu_head,
is_comp_planner,
is_manager,
job_description,
job_id,
job_type,
last_hire_date,
last_name,
legal_first_name,
legal_last_name,
legal_middle_name,
legal_name,
manager_name,
middle_name,
name,
name_prefix,
name_suffix,
off_premises_date,
original_hire_date,
pay_group_country_code,
personal_cell_number,
personal_home_number,
physical_location_addr1,
physical_location_addr2,
physical_location_bldg_code,
physical_location_bldg_name,
physical_location_city_code,
physical_location_country_code,
physical_location_postal_code,
physical_location_region_code,
physical_location_state_code,
position_number,
product_cd,
product_desc,
region,
room_code,
room_location,
room_type,
short_country_code,
status,
status_flag,
termination_action_date,
termination_date,
vacation_credit_date,
vendor_name,
work_from_home
FROM (
	SELECT Emp_hierarchy.*, t.username,t.employee_category,
budget_location_addr1 
,budget_location_addr2,
budget_location_bldg_code,
budget_location_bldg_name,
budget_location_city_code,
budget_location_country_code,
budget_location_postal_code,
budget_location_region_code,
budget_location_state_code,
business_area_name,
business_cell_country_code,
business_cell_number,
business_phone_country_code,
business_phone_extension,
business_phone_number,
business_principal,
business_unit_code,
business_unit_name,
comp_planner_name,
company_code,
company_name,
department_name,
dj_employee_id,
email_address,
employee_class,
employee_class_description,
employee_status,
employee_type,
etl_processed_date,
first_name,
floor_code,
floor_information,
hr_partner_name,
is_bu_head,
is_comp_planner,
is_manager,
job_description,
job_id,
job_type,
last_hire_date,
last_name,
legal_first_name,
legal_last_name,
legal_middle_name,
legal_name,
manager_name,
middle_name,
name,
name_prefix,
name_suffix,
off_premises_date,
original_hire_date,
pay_group_country_code,
personal_cell_number,
personal_home_number,
physical_location_addr1,
physical_location_addr2,
physical_location_bldg_code,
physical_location_bldg_name,
physical_location_city_code,
physical_location_country_code,
physical_location_postal_code,
physical_location_region_code,
physical_location_state_code,
position_number,
product_cd,
product_desc,
region,
room_code,
room_location,
room_type,
short_country_code,
status,
status_flag,
termination_action_date,
termination_date,
vacation_credit_date,
vendor_name,
work_from_home
		,row_number() OVER (
			PARTITION BY t.last_name
			,t.first_name
			,t.dj_employee_id ORDER BY (
					CASE 
						WHEN Emp_hierarchy.sixth_level_manager IS NULL
							THEN 3
						WHEN t.is_manager = true
							AND Emp_hierarchy.sixth_level_manager IS NOT NULL
							AND Emp_hierarchy.fourth_level_manager IS NOT NULL
							AND Emp_hierarchy.fifth_level_manager IS NOT NULL
							THEN 2
						WHEN t.is_manager = true
							THEN 1
						ELSE 0
						END
					) DESC
				,(
					CASE 
						WHEN t.dj_employee_id LIKE 'dj%'
							THEN 1
						ELSE 0
						END
					) DESC
				,(
					CASE 
						WHEN Emp_hierarchy.reporting_employee_name = t.legal_name
							THEN 1
						ELSE 0
						END
					) DESC
			) rn
	FROM dimension_external_db.workday_employee_current t
	JOIN Emp_hierarchy ON CONCAT (
			t.last_name
			,','
			,t.first_name
			) = Emp_hierarchy.reporting_employee_name
		AND t.dj_employee_id = Emp_hierarchy.reporting_employee_id
	) TEMP
