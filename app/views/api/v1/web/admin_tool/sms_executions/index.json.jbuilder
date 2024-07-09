json.sms_executions @sms_executions.each do |sms_execution|
	json.id 							sms_execution.try(:id)
	json.name							sms_execution.try(:name)
	json.location_name		sms_execution.try(:location_name)
	json.branch_name			sms_execution.try(:branch_name)
end