index_value = 0
json.internees @internees.each do |internee|
	json.index_value 					index_value
	json.id 									internee.id
	json.internee_code 				internee.internee_code
	json.full_name 						internee.full_name
	json.combine_name 				"#{internee.internee_code} | #{internee.full_name}"
	json.location_name 				internee.location_name
	json.branch_name 					internee.branch_name
	json.department_name 			internee.department_name
	json.job_title_name 			internee.job_title_name
	json.grade_name 					internee.grade_name
	json.designation_name 		internee.designation_name
	json.joining_date 				ReportFormat.date_format(internee.joining_date)
	json.is_active 						internee.is_active
	json.is_converted 				internee.is_converted
	index_value = index_value + 1
end