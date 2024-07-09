json.user_id 								@user_session.try(:id)
json.email 									@user_session.try(:email)
json.auth_token 						@user_session.try(:authentication_token)
json.full_name 							@user_session.full_name
json.first_name 						@user_session.try(:first_name)
json.last_name 							@user_session.try(:last_name)
json.is_admin 							@user_session.try(:is_admin)
json.custom_right 					@user_session.try(:custom_right)
json.company_id 						@user_session.try(:company_id)
json.is_company_head 				@user_session.try(:is_company_head)
json.is_location_head 			@user_session.try(:is_location_head)
json.is_branch_head 				@user_session.try(:is_branch_head)
json.is_department_head 		@user_session.try(:is_department_head)
json.first_login 						@user_session.try(:first_login)
json.all_company_department @user_session.try(:all_company_department)
json.request_on_dashboard 	@user_session.try(:request_on_dashboard)
json.hris_dashboard 		    @user_session.try(:hris_dashboard)
json.salary_dashboard 		  @user_session.try(:salary_dashboard)
json.attendance_dashboard 	@user_session.try(:attendance_dashboard)

json.back_date_calculation 	SystemSetting.get_back_date_calculation(@user_session.company_id)
json.overtime_execption 		SystemSetting.overtime_execption(@user_session.company_id)
json.hide_religion 					SystemSetting.get_hide_religion(@user_session.company_id)
json.hide_religion_sect 		SystemSetting.get_hide_religion_sect(@user_session.company_id)
if @user_session.employee.nil?
  json.login_employee_id  nil
  json.is_employee        false
else  
  json.login_employee_id  @user_session.employee.id
  json.is_employee        true
end

json.user_permissions @user_permissions.each do |role_permission|
  json.main_module 							role_permission.try(:main_module)
	json.display_name 						role_permission.try(:display_name)
	json.module_name 							role_permission.try(:module_name)
	json.index_access 						role_permission.try(:index_access)
	json.create_access 						role_permission.try(:create_access)
	json.view_access 							role_permission.try(:view_access)
	json.update_access 						role_permission.try(:update_access)
	json.delete_access 						role_permission.try(:delete_access)
end

if @user_session.employee.nil?
	json.leave_request_count 										0
	json.leave_approval_request_count						0
	json.approval_request_count 								0
	json.od_request_count 											0
	json.od_approval_request_count 							0
	json.relaxation_request_count 							0
	json.relaxation_approval_request_count 			0
else
	json.leave_request_count 										LeaveRequest.where(:employee_id => @user_session.employee.id, :request_status => "Waiting For Approval").count
	json.leave_approval_request_count 					ApprovalRequest.where(:request_receiver_id => @user_session.employee.id, :approval_request_status => "Waiting For Approval", :requestable_type => "LeaveRequest").count
	json.approval_request_count 								ApprovalRequest.where(:request_receiver_id => @user_session.employee.id, :approval_request_status => "Waiting For Approval").count
	json.od_request_count 											OfficialDuty.where(:employee_id => @user_session.employee.id, :request_status => "Waiting For Approval").count
	json.od_approval_request_count 							ApprovalRequest.where(:request_receiver_id => @user_session.employee.id, :approval_request_status => "Waiting For Approval", :requestable_type => "OfficialDuty").count
	json.relaxation_request_count               RelaxationRequest.where(:employee_id => @user_session.employee.id, :request_status => "Waiting For Approval").count
  json.relaxation_approval_request_count      ApprovalRequest.where(:request_receiver_id => @user_session.employee.id, :approval_request_status => "Waiting For Approval", :requestable_type => "RelaxationRequest").count
end