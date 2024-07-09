index_count = 0
json.objective_settings @objective_settings.each do |objective_setting|
  json.index_value								index_count
  json.id 												objective_setting.try(:id)
  json.starting_weight 						objective_setting.try(:starting_weight)
  json.ending_weight 							objective_setting.try(:ending_weight)
  # json.task_ids      							objective_setting.try(:task_ids).split(',').map(&:to_i)
  # json.sub_task_ids  							objective_setting.try(:sub_task_ids).split(',').map(&:to_i)
  employee = Employee.find(objective_setting.try(:employee_id))
  json.employee_id 				employee.employee_code
  json.employee_name   						objective_setting.try(:employee_name)
  json.fiscal_year_id   					objective_setting.try(:fiscal_year_id)
  json.status        							objective_setting.try(:status)
  json.comments      							objective_setting.objective_comments.count
  index_count = index_count + 1
end