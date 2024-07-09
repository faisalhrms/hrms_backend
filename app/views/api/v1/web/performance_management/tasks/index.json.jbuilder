avg_score = 0.0
total_line_obj_avg_score = 0
line_obj_net_score = 0
json.tasks @tasks do |task|
  json.id   			task.try(:id)
  json.goal 			task.try(:goal)
  begin
    employee = Employee.find(params[:id])
  rescue
    employee = Employee.find_by_employee_code(params[:id])
  end
  if not employee.present?
    begin
      employee = Employee.find(task.try(:employee_id))
    rescue
      employee = Employee.find_by_employee_code(task.try(:employee_id))
    end
  end
  json.employee_id 				employee.employee_code
  json.due_date   ReportFormat.date_format(task.try(:due_date))
  if task.start_date.present?
    json.start_date   ReportFormat.date_format(task.try(:start_date))
  else
    json.start_date   nil
  end
  json.start_date
  json.weight     task.try(:weight)
  json.achievement_date   ReportFormat.date_format(task.try(:achievement_date))
  json.employee_rating     task.try(:employee_rating)
  if params["action"] == "index2"
    json.line_manager_rating     "-"
  else
    json.line_manager_rating     task.try(:line_manager_rating)
  end
  total_line_obj_avg_score = total_line_obj_avg_score + (((task.try(:weight).to_f)/100)*task.try(:line_manager_rating).to_i)
  # avg_score = avg_score + (task.try(:weight).to_f/100 * (task.try(:line_manager_rating).to_i))
  json.kpis     task.sub_tasks.pluck(:id, :kpi)
end
if total_line_obj_avg_score > 5.0
  total_line_obj_avg_score = 5.0
end
line_obj_net_score = (total_line_obj_avg_score * 0.80).round(2)
json.avg_score  total_line_obj_avg_score.round(2)
json.net_score  (line_obj_net_score).round(2)

json.can_update_appraisal @objective_setting.try(:line_manager_appraisal_approval) != 'Approved'
json.can_update_appraisal2 @objective_setting.try(:appraisal_status) != 'Approved'
