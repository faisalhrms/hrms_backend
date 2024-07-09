index_count = 0
total_score = 0
competency_count = @appraisals.count

total_competency = Competency.all.count
total_line_comp_rating = 0
line_comp_net_score = 0

json.appraisals @appraisals.each do |appraisal|
  index_count = index_count + 1
  json.index_value								index_count
  json.id 												appraisal.try(:id)
  json.competency_id   						appraisal.try(:competency_id)
  json.employee_id   							appraisal.try(:employee_id)
  json.employee_rating   					appraisal.try(:employee_rating).to_i > 0 ? appraisal.try(:employee_rating).to_i : 1
  json.line_manager_rating   			appraisal.try(:line_manager_rating).to_i > 0 ? appraisal.try(:line_manager_rating).to_i : 1
  json.title   							      appraisal.try(:title)
  json.description   							appraisal.try(:description)
  # total_score = total_score + appraisal.try(:line_manager_rating).to_i
  total_line_comp_rating = total_line_comp_rating + appraisal.try(:line_manager_rating).to_i
end

line_comp_net_score = ((total_line_comp_rating.to_f / total_competency)).round(2)
if line_comp_net_score > 5.0
  line_comp_net_score = 5.0
end
json.employee_comments @comment.try(:employee_comments)
json.line_manager_comments @comment.try(:line_manager_comments)
json.functional @comment.try(:functional)
json.leadership @comment.try(:leadership)
json.career_aspiration @comment.try(:career_aspiration)

json.total_score line_comp_net_score
# net_score = ((total_score.to_f / competency_count) * 0.20).round(2)
json.net_score (line_comp_net_score * 0.20).round(2)

json.can_update @objective_setting.try(:status) != 'Approved'
json.can_update_appraisal @objective_setting.try(:line_manager_appraisal_approval) != 'Approved'
json.can_update_appraisal2 @objective_setting.try(:appraisal_status) != 'Approved'

avg_score = 0.0
total_line_obj_avg_score = 0
line_obj_net_score = 0
json.tasks @tasks do |task|
  json.id   			task.try(:id)
  json.goal 			task.try(:goal)
  json.employee_id 			task.try(:employee_id)
  json.due_date   ReportFormat.date_format(task.try(:due_date))
  if task.start_date.present?
    json.start_date   ReportFormat.date_format(task.try(:start_date))
  else
    json.start_date   nil
  end
  json.weight     task.try(:weight)
  json.achievement_date   ReportFormat.date_format(task.try(:achievement_date))
  json.employee_rating     task.try(:employee_rating)
  json.line_manager_rating     task.try(:line_manager_rating)
  total_line_obj_avg_score = total_line_obj_avg_score + (((task.try(:weight).to_f)/100)*task.try(:line_manager_rating).to_i)
  # avg_score = avg_score + (task.try(:weight).to_f/100 * (task.try(:line_manager_rating).to_i))
  json.kpis     task.sub_tasks.pluck(:id, :kpi)
end
if total_line_obj_avg_score > 5.0
  total_line_obj_avg_score = 5.0
end
line_obj_net_score = (total_line_obj_avg_score * 0.80).round(2)
json.avg_score  total_line_obj_avg_score.round(2)
json.objective_net_score  (line_obj_net_score).round(2)

json.total_net_score (line_obj_net_score + (line_comp_net_score * 0.20)).round(2)