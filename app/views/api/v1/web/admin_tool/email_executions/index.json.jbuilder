json.email_executions @email_executions.each do |email_execution|
	json.id 							email_execution.try(:id)
	json.name							email_execution.try(:name)
	json.location_name		email_execution.try(:location_name)
	json.branch_name			email_execution.try(:branch_name)
end