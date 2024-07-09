json.leave_list @employees.each do |employee|
	json.employee_name 					employee.full_name
	json.employee_code 					employee.employee_code
	json.location_name					employee.location_name
	json.branch_name						employee.branch_name
	json.department_name				employee.department_name
	json.grade_name							employee.grade_name
	json.designation_name				employee.designation_name
  json.joining_date 					ReportFormat.date_format(employee.joining_date)
  leave_types 		= LeaveType.where(:is_active => true, :is_composite => false).order('sort_order ASC')
	sick_leaves 		= leave_types.where(:short_name => "SL")
	casual_leaves 	= leave_types.where(:short_name => "CL")
	annual_leaves 	= leave_types.where(:short_name => "AL")
	cpl_leaves 			= leave_types.where(:short_name => "CPL")


  sick_leave_allocation 	= LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => sick_leaves.collect(&:id))
  casual_leave_allocation = LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => casual_leaves.collect(&:id))
  annual_leave_allocation = LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => annual_leaves.collect(&:id))
  cpl_leave_allocation 		= LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => cpl_leaves.collect(&:id))

  if not sick_leave_allocation.nil?
  	sick_balance 					= sick_leave_allocation.remaining_quota
  	sick_used_quota 			= sick_leave_allocation.used_quota
  	sick_allocated_quota 	= sick_leave_allocation.allocated_quota
  else
  	sick_balance 					= 0
  	sick_used_quota 			= 0
		sick_allocated_quota 	= 0
  end

  if not casual_leave_allocation.nil?
		casual_balance 					= casual_leave_allocation.remaining_quota
		casual_used_quota 			= casual_leave_allocation.used_quota
		casual_allocated_quota 	= casual_leave_allocation.allocated_quota
	else
		casual_balance 					= 0
		casual_used_quota 			= 0
		casual_allocated_quota 	= 0
	end

	if not annual_leave_allocation.nil?
		annual_balance 					= annual_leave_allocation.remaining_quota
		annual_used_quota 			= annual_leave_allocation.used_quota
		annual_allocated_quota 	= annual_leave_allocation.allocated_quota
	else
		annual_balance 					= 0
		annual_used_quota 			= 0
		annual_allocated_quota 	= 0
	end

	if not cpl_leave_allocation.nil?
		cpl_quota		= cpl_leave_allocation.allocated_quota
		cpl_availed	= cpl_leave_allocation.used_quota
		cpl_balance	= cpl_leave_allocation.remaining_quota
	else
		cpl_quota 	= 0
		cpl_availed = 0
		cpl_balance = 0
	end

	total_availed_leaves 	= sick_used_quota + casual_used_quota + annual_used_quota
	total_allocated_quota = sick_allocated_quota + casual_allocated_quota + annual_allocated_quota
	
	leave_encashment_balance = 0
	if not sick_leave_allocation.nil?
		if sick_leave_allocation.leave_type.encashment == true
			leave_encashment_balance = leave_encashment_balance + sick_leave_allocation.remaining_quota
		end
	end

	if not casual_leave_allocation.nil?
		if casual_leave_allocation.leave_type.encashment == true
			leave_encashment_balance = leave_encashment_balance + casual_leave_allocation.remaining_quota
		end
	end

	if not annual_leave_allocation.nil?
		if annual_leave_allocation.leave_type.encashment == true
			leave_encashment_balance = leave_encashment_balance + annual_leave_allocation.remaining_quota
		end
	end
	 
	json.sick_balance							sick_balance.round(2)
	json.casual_balance 					casual_balance.round(2)
	json.annual_balance 					annual_balance.round(2)
	json.leave_encashment_balance leave_encashment_balance.round(2)
	json.total_availed_leaves 		total_availed_leaves.round(2)
	json.total_allocated_quota 		total_allocated_quota.round(2)
	json.cpl_quota 								cpl_quota.round(2)
	json.cpl_availed 							cpl_availed.round(2)
	json.cpl_balance 							cpl_balance.round(2)
end
