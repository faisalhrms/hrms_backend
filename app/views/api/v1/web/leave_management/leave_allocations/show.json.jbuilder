json.leave_allocation do
	json.id 							@leave_allocation.id
	json.leave_status			@leave_allocation.is_active
	begin
		json.avatar @leave_allocation.employee.try(:avatar).url
	  json.avatar_file_name @leave_allocation.employee.try(:avatar_file_name)
		if @leave_allocation.employee.avatar_file_name.nil? or @leave_allocation.employee.avatar_file_name.blank?
	    json.avatar_present false
	  else
	    json.avatar_present true
	  end
	rescue Exception => e
		json.avatar ""
		json.avatar_file_name ""
		json.avatar_present false
	end
	json.employee_id 									@leave_allocation.employee.id
	json.employee_name 								@leave_allocation.employee.full_name 
	json.employee_code 								@leave_allocation.employee.employee_code
	json.leave_type										@leave_allocation.leave_type_name
	if @in_process_leave == true
		if @leave_allocation.leave_type.is_composite == false
			in_process_quota 								= @leave_allocation.in_process_quota
			json.allocated_quota						@leave_allocation.allocated_quota
			json.used_quota									(@leave_allocation.used_quota - in_process_quota)
			json.remaining_quota						@leave_allocation.remaining_quota.try(:round,2)
			json.in_process_quota						in_process_quota
		else
			in_process_quota 								= @leave_allocation.composite_in_process_quota
			json.allocated_quota						@leave_allocation.composite_allocated_quota
			json.used_quota									(@leave_allocation.composite_used_quota - in_process_quota)
			json.remaining_quota						@leave_allocation.composite_remaining_quota.try(:round,2)
			json.in_process_quota						in_process_quota
		end
	else
		if @leave_allocation.leave_type.is_composite == false
			json.allocated_quota						@leave_allocation.allocated_quota
			json.used_quota									@leave_allocation.used_quota
			json.remaining_quota						@leave_allocation.remaining_quota.try(:round,2)
			json.in_process_quota						"-"
		else
			json.allocated_quota						@leave_allocation.composite_allocated_quota
			json.used_quota									@leave_allocation.composite_used_quota
			json.remaining_quota						@leave_allocation.composite_remaining_quota.try(:round,2)
			json.in_process_quota						"-"
		end
	end
	json.location_name 								@leave_allocation.employee.location_name
	json.branch_name 									@leave_allocation.employee.branch_name
	json.department_name 							@leave_allocation.employee.department_name
	json.job_title_name 							@leave_allocation.employee.job_title_name
	json.grade_name 									@leave_allocation.employee.grade_name
	json.display_joining_date 				ReportFormat.date_format(@leave_allocation.employee.joining_date)
end

if @leave_allocation.leave_type.is_composite == false
	json.leave_transaction_histories	LeaveTransactionHistory.where(:leave_allocation_id => @leave_allocation.id, :company_id => @leave_allocation.company_id, :leave_type_id => @leave_allocation.leave_type_id, :employee_id => @leave_allocation.employee_id).order('id DESC').each do |leave_transaction_history|
		if leave_transaction_history.leave_request_id.nil?
			json.is_leave_request "No"
		else
			json.is_leave_request "Yes"
		end
		json.allocated_quota 					leave_transaction_history.allocated_quota
		json.remaining_quota 					leave_transaction_history.remaining_quota.try(:round,2)
		json.used_quota 							leave_transaction_history.used_quota
		json.quota_transaction 				leave_transaction_history.quota_transaction
		json.transaction_type 				leave_transaction_history.transaction_type
		json.remarks 									leave_transaction_history.remarks
		json.transaction_date 				ReportFormat.date_format(leave_transaction_history.transaction_date)
		json.leave_year_start_date 		ReportFormat.date_format(leave_transaction_history.leave_year_start_date)
		json.leave_year_end_date 			ReportFormat.date_format(leave_transaction_history.leave_year_end_date)
		json.leave_type_name 					leave_transaction_history.leave_type.name
	end
else
	leave_type_ids = @leave_allocation.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
	leave_allocation_ids = LeaveAllocation.where(:leave_type_id => leave_type_ids, :is_active => true, :employee_id => @leave_allocation.employee_id).collect(&:id)
	json.leave_transaction_histories	LeaveTransactionHistory.where(:leave_allocation_id => leave_allocation_ids, :company_id => @leave_allocation.company_id, :leave_type_id => leave_type_ids, :employee_id => @leave_allocation.employee_id).order('id DESC').each do |leave_transaction_history|
		if leave_transaction_history.leave_request_id.nil?
			json.is_leave_request "No"
		else
			json.is_leave_request "Yes"
		end
		json.allocated_quota 					leave_transaction_history.allocated_quota
		json.remaining_quota 					leave_transaction_history.remaining_quota.try(:round,2)
		json.used_quota 							leave_transaction_history.used_quota
		json.quota_transaction 				leave_transaction_history.quota_transaction
		json.transaction_type 				leave_transaction_history.transaction_type
		json.remarks 									leave_transaction_history.remarks
		json.transaction_date 				ReportFormat.date_format(leave_transaction_history.transaction_date)
		json.leave_year_start_date 		ReportFormat.date_format(leave_transaction_history.leave_year_start_date)
		json.leave_year_end_date 			ReportFormat.date_format(leave_transaction_history.leave_year_end_date)
		json.leave_type_name 					leave_transaction_history.leave_type.name
	end
end