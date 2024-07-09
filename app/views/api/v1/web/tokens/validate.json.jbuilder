json.user_id 						     @user.try(:id)
json.email 							     @user.try(:email)
json.auth_token 				     @user.try(:authentication_token)
json.full_name 					     @user.full_name
json.first_name 				     @user.try(:first_name)
json.last_name 					     @user.try(:last_name)
json.is_admin 					     @user.try(:is_admin)
json.custom_right 			     @user.try(:custom_right)
json.company_id 				     @user.try(:company_id)
json.is_company_head 		     @user.try(:is_company_head)
json.is_location_head 	     @user.try(:is_location_head)
json.is_branch_head 		     @user.try(:is_branch_head)
json.is_department_head      @user.try(:is_department_head)
json.request_on_dashboard    @user.try(:request_on_dashboard)
json.all_company_department  @user.try(:all_company_department)
json.first_login             @user.try(:first_login)
json.hris_dashboard          @user.try(:hris_dashboard)
json.salary_dashboard        @user.try(:salary_dashboard)
json.attendance_dashboard    @user.try(:attendance_dashboard)

json.back_date_calculation   SystemSetting.get_back_date_calculation(@user.company_id)
json.overtime_execption      SystemSetting.overtime_execption(@user.company_id)
json.hide_religion           SystemSetting.get_hide_religion(@user.company_id)
json.hide_religion_sect      SystemSetting.get_hide_religion_sect(@user.company_id)
if @user.employee.nil?
  json.login_employee_id  nil
  json.is_employee        false
else  
  json.login_employee_id  @user.employee.id
  json.is_employee        true
end

count = 0
# json.lastest_notifications @notis.each do |a_noti|
#   json.id 				a_noti.try(:id)
#   json.noti_date 	a_noti.notification.created_at.localtime.strftime("%B %d, %Y, %I:%M:%S %p")
#   json.content 		a_noti.try(:content)
#   json.did_read 	a_noti.try(:did_read)
#   if a_noti.did_read == false
#     count = count + 1
#   end
# end

json.lastest_notifications []
json.un_read_noti_count count

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

if @user.employee.nil?
  json.leave_request_count                    0
  json.leave_approval_request_count           0
  json.approval_request_count                 0
  json.od_request_count                       0
  json.od_approval_request_count              0
  json.relaxation_request_count               0
  json.relaxation_approval_request_count      0
else
  json.pending_obj_approval_count            ObjectiveSetting.where(employee_id: Employee.where(line_manager_id: @user.employee.id).ids, line_manager_approval: 'Approved').where.not(status: 'Approved').count
  json.pending_app_approval_count            ObjectiveSetting.where(employee_id: Employee.where(line_manager_id: @user.employee.id).ids, line_manager_appraisal_approval: 'Approved').where(appraisal_status: 'Pending', status: 'Approved').count
  json.pending_hod_approval_count            ObjectiveSetting.where(employee_id: Employee.where(line_manager_id: @user.employee.id).ids, line_manager_appraisal_approval: 'Approved').where(hod_approval_status: 'Pending', appraisal_status: 'Approved').count
  json.is_line_manager                        Employee.where(:id => @user.employee.id, :is_line_manager => "true").present?
  json.is_admin                               @user.is_admin
  json.leave_request_count                    LeaveRequest.where(:employee_id => @user.employee.id, :request_status => ["Waiting For Approval", "Waiting For 2nd Approval"]).count
  json.leave_approval_request_count           ApprovalRequest.where(:request_receiver_id => @user.employee.id, :approval_request_status => ["Waiting For Approval", "Waiting For 2nd Approval"], :requestable_type => "LeaveRequest").count
  json.approval_request_count                 ApprovalRequest.where(:request_receiver_id => @user.employee.id, :approval_request_status => ["Waiting For Approval", "Waiting For 2nd Approval"]).count
  json.od_request_count                       OfficialDuty.where(:employee_id => @user.employee.id, :request_status => ["Waiting For Approval", "Waiting For 2nd Approval"]).count
  json.od_approval_request_count              ApprovalRequest.where(:request_receiver_id => @user.employee.id, :approval_request_status => ["Waiting For Approval", "Waiting For 2nd Approval"], :requestable_type => "OfficialDuty").count
  json.relaxation_request_count               RelaxationRequest.where(:employee_id => @user.employee.id, :request_status => ["Waiting For Approval", "Waiting For 2nd Approval"]).count
  json.relaxation_approval_request_count      ApprovalRequest.where(:request_receiver_id => @user.employee.id, :approval_request_status => ["Waiting For Approval", "Waiting For 2nd Approval"], :requestable_type => "RelaxationRequest").count
end