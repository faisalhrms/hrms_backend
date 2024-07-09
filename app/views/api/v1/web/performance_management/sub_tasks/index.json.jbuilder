total_weight = 0
index = 0
if @tasks
  json.tasks @tasks do |task|
    json.id   			task.try(:id)
    json.goal 			task.try(:goal)
    json.due_date   task.try(:due_date).to_date.try(:strftime, '%Y-%m-%d')
    if task.start_date.present?
      json.start_date   task.try(:start_date).to_date.try(:strftime, '%Y-%m-%d')
    else
      json.start_date   nil
    end
    json.weight     task.try(:weight)
    json.achievement_data   task.try(:achievement_data).try(:strftime, '%Y-%m-%d')
    json.employee_rating     task.try(:employee_rating)
    json.line_manager_rating     task.try(:line_manager_rating)
    json.kpis     task.sub_tasks.pluck(:id, :kpi)
    total_weight = total_weight + task.try(:weight).to_i
    json.total_weight total_weight
    index = index + 1
    json.index index
  end
  json.status @objective_setting.try(:status)
  json.appraisal_status @objective_setting.try(:appraisal_status)
  json.hod_approval_status @objective_setting.try(:hod_approval_status)
  json.objective_setting_id @objective_setting.try(:id)
end
json.can_update @objective_setting.try(:status) != 'Approved'
json.can_update_hod @objective_setting.try(:hod_approval_status) != 'Approved'
json.can_update_appraisal @objective_setting.try(:appraisal_status) != 'Approved'