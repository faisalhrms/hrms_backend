json.sms_template do 
	json.id 										@sms_template.try(:id)
	json.company_id 						@sms_template.try(:company_id)
	json.sms_configration_id 		@sms_template.try(:sms_configration_id)
	json.name 									@sms_template.try(:name)
	json.is_active 							@sms_template.try(:is_active)
	json.is_exempted 						@sms_template.try(:is_exempted)
	json.exempted_numbers 			@sms_template.try(:exempted_numbers)
	json.trigger 								@sms_template.try(:trigger)
	json.message 								@sms_template.try(:message)
end