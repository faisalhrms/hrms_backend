json.email_templates @email_templates.each do |email_template|
	json.id 										email_template.try(:id)
	json.company_id 						email_template.try(:company_id)
	json.email_configration_id 	email_template.try(:email_configration_id)
	json.name 									email_template.try(:name)
	json.subject 								email_template.try(:subject)
	json.trigger 								email_template.try(:trigger)
	json.cc_address 						email_template.try(:cc_address)
	json.is_cc 									email_template.try(:is_cc)
	json.message 								email_template.try(:message)
	json.is_active 							email_template.try(:is_active)
end