json.employees @employee_next_of_kins.order('employee_id ASC').each do |employee_next_of_kin|
	json.employee_code 											employee_next_of_kin.employee_code
	json.full_name 													employee_next_of_kin.employee_name
	json.relative_name 											employee_next_of_kin.employee_relative_name
	json.relationship_name 									employee_next_of_kin.relationship_name
	json.guardian_name											employee_next_of_kin.guardian_name
	json.relative_age 											employee_next_of_kin.relative_age
	json.percentage 												employee_next_of_kin.percentage
end