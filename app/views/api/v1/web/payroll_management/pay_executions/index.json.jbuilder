json.pay_executions @pay_executions.each do |pay_execution|
	json.id 								pay_execution.try(:id)
	json.name 							pay_execution.try(:name)
	json.location_name 			pay_execution.location_name
	json.formated_pay_month pay_execution.try(:formated_pay_month)
	json.no_of_pay_days 		pay_execution.try(:no_of_pay_days)
	json.is_generated 			pay_execution.try(:is_generated)
	json.is_locked 					pay_execution.try(:is_locked)
end