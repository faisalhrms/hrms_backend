json.leave_allocations @leave_allocations.each do |leave_allocation|
	json.id 							leave_allocation.id
	json.employee_name 		leave_allocation.employee.full_name 
	json.employee_code 		leave_allocation.employee.employee_code
	json.leave_type				leave_allocation.leave_type_name
	if @in_process_leave == true
		if leave_allocation.leave_type.is_composite == false
			in_process_quota 				= leave_allocation.in_process_quota
			json.allocated_quota		leave_allocation.allocated_quota
			json.used_quota					(leave_allocation.used_quota - in_process_quota)
			json.remaining_quota		leave_allocation.remaining_quota.try(:round,2)
			json.in_process_quota		in_process_quota
		else
			in_process_quota 				= leave_allocation.composite_in_process_quota
			json.allocated_quota		leave_allocation.composite_allocated_quota
			json.used_quota					(leave_allocation.composite_used_quota - in_process_quota)
			json.remaining_quota		leave_allocation.composite_remaining_quota.try(:round,2)
			json.in_process_quota		in_process_quota
		end
	else
		if leave_allocation.leave_type.is_composite == false
			json.allocated_quota		leave_allocation.allocated_quota
			json.used_quota					leave_allocation.used_quota
			json.remaining_quota		leave_allocation.remaining_quota.try(:round,2)
			json.in_process_quota		"-"
		else
			json.allocated_quota		leave_allocation.composite_allocated_quota
			json.used_quota					leave_allocation.composite_used_quota
			json.remaining_quota		leave_allocation.composite_remaining_quota.try(:round,2)
			json.in_process_quota		"-"
		end
	end
	json.is_active				leave_allocation.is_active
end