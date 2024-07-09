json.department_allocation_details @departments.each do |department|
	json.department_id 								department.id
	json.department_name 							department.name
	json.is_selected									false
end