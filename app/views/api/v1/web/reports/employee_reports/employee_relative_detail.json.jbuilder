json.employees @employee_relatives.order('employee_id ASC').each do |employee_relative|
	json.employee_code 											employee_relative.employee_code
	json.full_name 													employee_relative.employee_name
	json.relative_name 											employee_relative.relative_name
	json.relationship_name 									employee_relative.relationship_name
	json.email 															employee_relative.email
	json.contact_number 										ReportFormat.phone_format(employee_relative.contact_number)
	json.date_of_birth 											ReportFormat.date_format(employee_relative.date_of_birth)
	json.date_of_enrollment									ReportFormat.date_format(employee_relative.date_of_enrollment)
	json.gender 														employee_relative.gender
	json.cnic_number 												ReportFormat.cnic_format(employee_relative.cnic_number)
	json.is_dependent 											ReportFormat.boolean_in_text(employee_relative.is_dependent)
	json.insurance_allowed									ReportFormat.boolean_in_text(employee_relative.insurance_allowed)
	json.same_as_employee_address 					ReportFormat.boolean_in_text(employee_relative.same_as_employee_address)
	json.same_as_employee_permanent_address ReportFormat.boolean_in_text(employee_relative.same_as_employee_address)
	json.address 														employee_relative.address
	if employee_relative.date_of_birth.nil?
		json.relative_age 										0
	else	
		json.relative_age 										Time.now.year - employee_relative.date_of_birth.year
	end
end