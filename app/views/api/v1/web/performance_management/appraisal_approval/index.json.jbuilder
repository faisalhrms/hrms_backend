index_count = 0
json.appraisal_approvals @appraisal_approvals.each do |appraisal_approval|
  json.index_value								index_count
  json.id 												appraisal_approval.try(:id)
  json.net_score 						appraisal_approval.try(:net_score)
  json.objective_id 							appraisal_approval.try(:objective_id)
  json.employee_id   							appraisal_approval.try(:employee_id)
  json.status   							appraisal_approval.try(:status)
  json.comments   							appraisal_approval.try(:comments)
  index_count = index_count + 1
end