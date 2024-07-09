json.sms_configrations @sms_configrations.each do |sms_configration|
	json.id 											sms_configration.try(:id)
	json.name											sms_configration.try(:name)
	json.user_name								sms_configration.try(:user_name)
	json.is_active								sms_configration.try(:is_active)
end