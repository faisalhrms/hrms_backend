json.objective_setting do
  json.id 															@objective_setting.try(:id)
  json.starting_weight 									@objective_setting.try(:starting_weight)
  json.ending_weight 										@objective_setting.try(:ending_weight)
  employee = Employee.find(@objective_setting.try(:employee_id))
  json.employee_id 				employee.employee_code
  json.employee_name 										@objective_setting.try(:employee_name)
  json.fiscal_year_id 								  @objective_setting.try(:fiscal_year_id)
  json.status          								  @objective_setting.try(:status)
  json.comments        								  @objective_setting.objective_comments.count
  json.task_ids 											  @objective_setting.try(:task_ids).split(',').map(&:to_i)
  json.sub_task_ids 										@objective_setting.try(:sub_task_ids).split(',').map(&:to_i)
end