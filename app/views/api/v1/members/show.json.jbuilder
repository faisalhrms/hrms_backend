json.user do
	json.id 										@member.try(:id)
	json.first_name 						@member.try(:first_name)
	json.last_name 							@member.try(:last_name)
	json.full_name 							@member.full_name
	json.email 									@member.try(:email)
	json.is_active 							@member.try(:is_active)
	json.is_admin 							@member.try(:is_admin)
  json.is_dtl    							@member.try(:is_dtl)
  json.is_wager    						@member.try(:is_wager)
  json.is_piece_rate    			@member.try(:is_piece_rate)
  json.custom_right 					@member.try(:custom_right)
	json.role_id 								@member.try(:role_id)
	json.company_id 						@member.try(:company_id)
	json.is_company_head 				@member.try(:is_company_head)
	json.is_location_head 			@member.try(:is_location_head)
	json.is_branch_head 				@member.try(:is_branch_head)
	json.is_department_head 		@member.try(:is_department_head)
	json.is_sub_department_head @member.try(:is_sub_department_head)
	json.multi_branch_allowed   @member.try(:multi_branch_allowed)
	json.all_company_department @member.try(:all_company_department)
	json.request_on_dashboard 	@member.try(:request_on_dashboard)
  json.hris_dashboard 				@member.try(:hris_dashboard)
  json.salary_dashboard 			@member.try(:salary_dashboard)
  json.attendance_dashboard		@member.try(:attendance_dashboard)

  if @member.branch_ids.nil?
		json.branch_ids 					""	
	else
		json.branch_ids						@member.try(:branch_ids).split(',').map(&:to_i)
	end
	if @member.employee.nil?
		json.is_employee 			false
	else
		json.is_employee 			true
	end
end