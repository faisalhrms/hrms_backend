json.company do
  json.id           						@company.try(:id)
  json.name 										@company.try(:name)
	json.code 										@company.try(:code)
	json.short_name 							@company.try(:short_name)
	json.address 									@company.try(:address)
	json.description 							@company.try(:description)
	json.is_active 								@company.try(:is_active)
	json.employee_code_prefix 		@company.try(:employee_code_prefix)
  json.ntn_number 							@company.try(:ntn_number)
	begin
		json.avatar @company.try(:avatar).url
	  json.avatar_file_name @company.try(:avatar_file_name)
		if @company.avatar_file_name.nil? or @company.avatar_file_name.blank?
	    json.avatar_present false
	  else
	    json.avatar_present true
	  end
	rescue Exception => e
		json.avatar ""
		json.avatar_file_name ""
		json.avatar_present false
	end
end