index_value = 0
json.temporary_staffs @temporary_staffs.each do |temporary_staff|
	json.index_value 						index_value
	json.id 										temporary_staff.id
	json.temporary_staff_code 	temporary_staff.temporary_staff_code
	json.full_name 							temporary_staff.full_name
	json.combine_name 					"#{temporary_staff.temporary_staff_code} | #{temporary_staff.full_name}"
	json.location_name 					temporary_staff.location_name
	json.branch_name 						temporary_staff.branch_name
	json.department_name 				temporary_staff.department_name
	json.job_title_name 				temporary_staff.job_title_name
	json.grade_name 						temporary_staff.grade_name
	json.designation_name 			temporary_staff.designation_name
	json.joining_date 					ReportFormat.date_format(temporary_staff.joining_date)
	json.is_active 							temporary_staff.is_active
	json.is_converted 					temporary_staff.is_converted
	index_value = index_value + 1
end