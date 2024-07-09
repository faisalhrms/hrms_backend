if @objective_settings.present?
  index_count = 0
  json.objective_settings @objective_settings.each do |objective_setting|
    json.index_value								index_count
    json.id 												objective_setting.try(:id)
    json.starting_weight 						objective_setting.try(:starting_weight)
    json.ending_weight 							objective_setting.try(:ending_weight)
    # employee = Employee.find(objective_setting.try(:employee_id))
    json.employee_id 				        objective_setting.try(:employee_id)
    json.employee_name   						objective_setting.try(:employee_name)
    json.fiscal_year_id   					objective_setting.try(:fiscal_year_id)
    json.status   							    objective_setting.try(:status)
    json.appraisal_status   				objective_setting.try(:appraisal_status)
    json.can_update_appraisal2   		objective_setting.try(:appraisal_status) != "Approved"
    json.hod_approval_status   			objective_setting.try(:hod_approval_status)
    json.comments   							  objective_setting.objective_comments.count
    if objective_setting.employee.department_id != 21
      json.show_button true
    else
      json.show_button false
    end
    index_count = index_count + 1
  end
  if @current_user.present?
    if @current_user.employee.present?
      if @current_user.employee.department_id != 21
        json.show_button true
      else
        json.show_button false
      end
    else
      json.show_button false
    end
  else
    json.show_button false
  end
end
