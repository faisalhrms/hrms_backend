json.grade_allocations @grade_allocations.each do |grade_allocation|
	json.id 								grade_allocation.id
	json.location_name			grade_allocation.location_name
	json.branch_name				grade_allocation.branch_name
	json.name 							grade_allocation.name
	json.no_of_grades 			grade_allocation.grade_allocation_details.where(:is_selected => true).count
end