json.department_allocations @department_allocations.each do |department_allocation|
	json.id 								department_allocation.id
	json.location_name			department_allocation.location_name
	json.branch_name				department_allocation.branch_name
	json.name 							department_allocation.name
	json.no_of_department 	department_allocation.department_allocation_details.where(:is_selected => true).count
end