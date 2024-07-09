json.sms_configration do 
	json.id 											@sms_configration.try(:id)
	json.company_id								@sms_configration.try(:company_id)
	json.name											@sms_configration.try(:name)
	json.user_name								@sms_configration.try(:user_name)
	json.url											@sms_configration.try(:url)
	json.password									@sms_configration.try(:password)
	json.masking									@sms_configration.try(:masking)
	json.is_active								@sms_configration.try(:is_active)
end