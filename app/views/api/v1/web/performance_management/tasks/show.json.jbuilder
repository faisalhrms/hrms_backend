json.task do
  json.id           						@task.try(:id)
  json.goal 										@task.try(:goal)
  json.weight 									@task.try(:weight)
  json.due_date 							  ReportFormat.date_format(@task.try(:due_date))
  if @task.start_date.present?
    json.start_date 							  ReportFormat.date_format(@task.try(:start_date))
  else
    json.start_date 							  nil
  end
  json.employee_rating 									@task.try(:employee_rating)
  json.achievement_date 							  ReportFormat.date_format(@task.try(:achievement_date))
end