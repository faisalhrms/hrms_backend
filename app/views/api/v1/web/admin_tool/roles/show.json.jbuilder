json.role do
  json.id           @role.try(:id)
  json.name         @role.try(:name)
  json.is_active    @role.try(:is_active)
  json.company_id   @role.try(:company_id)
  json.organization do
	  json.role_permissions @role.role_permissions.where(:main_module => "organization").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.admin_tool do
		json.role_permissions @role.role_permissions.where(:main_module => "admin_tool").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.employee_management do
		json.role_permissions @role.role_permissions.where(:main_module => "employee_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
  end
  json.performance_management do
    json.role_permissions @role.role_permissions.where(:main_module => "performance_management").order('id ASC').each do |role_permission|
      json.role_permission_id 			role_permission.try(:id)
      json.main_module 							role_permission.try(:main_module)
      json.display_name 						role_permission.try(:display_name)
      json.module_name 							role_permission.try(:module_name)
      json.index_access 						role_permission.try(:index_access)
      json.create_access 						role_permission.try(:create_access)
      json.view_access 							role_permission.try(:view_access)
      json.update_access 						role_permission.try(:update_access)
      json.delete_access 						role_permission.try(:delete_access)
    end
  end
	json.leave_management do
		json.role_permissions @role.role_permissions.where(:main_module => "leave_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.official_duty_management do
		json.role_permissions @role.role_permissions.where(:main_module => "official_duty_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.roster_management do
		json.role_permissions @role.role_permissions.where(:main_module => "roster_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.attendance_management do
		json.role_permissions @role.role_permissions.where(:main_module => "attendance_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.incentive_management do
		json.role_permissions @role.role_permissions.where(:main_module => "incentive_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.payroll_management do
		json.role_permissions @role.role_permissions.where(:main_module => "payroll_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.report_management do
		json.role_permissions @role.role_permissions.where(:main_module => "report_management").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
	json.main_menu do
		json.role_permissions @role.role_permissions.where(:main_module => "main_menu").order('id ASC').each do |role_permission|
			json.role_permission_id 			role_permission.try(:id)
			json.main_module 							role_permission.try(:main_module)
			json.display_name 						role_permission.try(:display_name)
			json.module_name 							role_permission.try(:module_name)
			json.index_access 						role_permission.try(:index_access)
			json.create_access 						role_permission.try(:create_access)
			json.view_access 							role_permission.try(:view_access)
			json.update_access 						role_permission.try(:update_access)
			json.delete_access 						role_permission.try(:delete_access)
		end
	end
end