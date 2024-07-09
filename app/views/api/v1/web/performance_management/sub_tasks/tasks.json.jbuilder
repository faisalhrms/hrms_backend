index = 0
if @tasks
  json.tasks @tasks do |task|
    json.id   			task.try(:id)
    json.employee_name 	task.try(:employee_name)
    json.appraisal_status     task.try(:appraisal_status)
    json.hod_approval_status     task.try(:hod_approval_status)
    index = index + 1
    json.index index

  end
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

json.can_update_appraisal @objective_setting.try(:line_manager_appraisal_approval) != 'Approved'