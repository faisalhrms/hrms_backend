json.leave_list @leave_allocations.each do |leave_allocation|
	if leave_allocation.employee.on_probation == false
		if leave_allocation.employee.employee_type_name != "Contractual"
			json.employee_name 					leave_allocation.employee_name
			json.employee_code 					leave_allocation.employee_code
			json.location_name					leave_allocation.location_name
			json.branch_name						leave_allocation.branch_name
			json.department_name				leave_allocation.department_name
			json.job_title_name					leave_allocation.job_title_name
			json.grade_name							leave_allocation.grade_name
			json.designation_name				leave_allocation.designation_name
		  json.leave_type_name 				leave_allocation.leave_type_name
		  json.remaining_quota 				leave_allocation.remaining_quota
		end
	end
end