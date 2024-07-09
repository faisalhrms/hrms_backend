json.email_configration do 
	json.id 											@email_configration.try(:id)
	json.company_id								@email_configration.try(:company_id)
	json.name											@email_configration.try(:name)
	json.user_name								@email_configration.try(:user_name)
	json.email										@email_configration.try(:email)
	json.password									@email_configration.try(:password)
	json.outgoing_server_address	@email_configration.try(:outgoing_server_address)
	json.outgoing_server_port			@email_configration.try(:outgoing_server_port)
	json.domain										@email_configration.try(:domain)
	json.is_active								@email_configration.try(:is_active)
end