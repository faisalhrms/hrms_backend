json.task do
  json.id 					@task.try(:id)
  json.goal 				@task.try(:goal)
  json.weight 				@task.try(:weight)
  begin
    employee = Employee.where(:id => @task.try(:employee_id))
    if employee.present?
      employee = employee.last
    else
      employee = Employee.find_by_employee_code(@task.try(:employee_id))
    end
  rescue
    employee = Employee.find_by_employee_code(@task.try(:employee_id))
  end
  if not employee.present?
    begin
      employee = Employee.find(@task.try(:employee_id))
    rescue
      employee = Employee.find_by_employee_code(@task.try(:employee_id))
    end
  end
  json.employee_id 				employee.id
  json.due_date 		@task.due_date.to_date.try(:strftime, '%Y-%m-%d')
  if @task.start_date.present?
    json.start_date 		@task.start_date.to_date.try(:strftime, '%Y-%m-%d')
  else
    json.start_date 		nil
  end
  json.employee_rating 				@task.try(:employee_rating).to_i > 0 ? @task.try(:employee_rating).to_i : 1
  json.line_manager_rating 				@task.try(:line_manager_rating).to_i > 0 ? @task.try(:line_manager_rating).to_i : 1
  json.achievement_date 		@task.achievement_date.try(:to_date).try(:strftime, '%Y-%m-%d')
  json.sub_task_slabs @task.sub_tasks.order('id ASC').each do |sub_task|
    json.slab_id											sub_task.try(:id)
    json.sub_task          								sub_task.try(:kpi)
  end
end
json.can_update_appraisal2 @objective_setting.try(:appraisal_status) != 'Approved'