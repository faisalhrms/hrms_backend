json.appraisals do
  json.id 															@appraisal.try(:id)
  json.employee_id 											@appraisal.try(:employee_id)
  json.competency_id 								  @appraisal.try(:competency_id)
  json.employee_rating                @appraisal.try(:employee_rating).to_i > 0 ? @appraisal.try(:employee_rating).to_i : 1
  json.line_manager_rating                @appraisal.try(:line_manager_rating).to_i > 0 ? @appraisal.try(:line_manager_rating).to_i : 1
end