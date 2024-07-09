json.grade_allocation_details @grades.each do |grade|
	json.grade_id 			grade.id
	json.grade_name 		grade.name
	json.is_selected		false
end