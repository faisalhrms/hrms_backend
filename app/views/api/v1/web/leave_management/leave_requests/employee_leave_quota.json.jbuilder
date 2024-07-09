json.allocated_leave do 
	if @leave_type.is_composite == false
		json.allocated_quota	@leave_allocation.allocated_quota
		json.used_quota				@leave_allocation.used_quota
		json.remaining_quota	@leave_allocation.remaining_quota
	else
		json.allocated_quota	@leave_allocation.composite_allocated_quota
		json.used_quota				@leave_allocation.composite_used_quota
		json.remaining_quota	@leave_allocation.composite_remaining_quota
	end
	json.employee_id			@leave_allocation.employee_id
end

json.leave_request_setting do
	if @leave_type.back_date_apply == true
		json.min_apply_date 					(Time.now - @leave_type.back_date_limit.day).to_date
	else
		json.min_apply_date 					(Time.now - 60.day).to_date
	end
end