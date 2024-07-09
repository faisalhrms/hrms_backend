json.employees @employee_references.order('employee_id ASC').each do |employee_reference|
	json.employee_code 								employee_reference.employee_code
	json.full_name 										employee_reference.employee_name
	json.reference_type 							employee_reference.reference_type
	json.name 												employee_reference.name
	json.email 												employee_reference.email
	json.contact_number 							ReportFormat.phone_format(employee_reference.contact_number)
	json.organization 								employee_reference.organization
	json.designation 									employee_reference.designation
	json.address 											employee_reference.address
end