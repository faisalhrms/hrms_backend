json.appraisal_approval do
  json.id 															@appraisal_approval.try(:id)
  json.employee_id 									    @appraisal_approval.try(:employee_id)
  json.objective_id 										@appraisal_approval.try(:objective_id)
  json.net_score 											  @appraisal_approval.try(:net_score)
  json.status 											  @appraisal_approval.try(:status)
  json.comments 											  @appraisal_approval.try(:comments)
end