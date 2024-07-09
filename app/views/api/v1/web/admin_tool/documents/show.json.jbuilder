json.document do
	json.id 					@document.try(:id)
	json.company_id		@document.try(:company_id)
	json.name					@document.try(:name)
	json.code					@document.try(:code)
	json.description	@document.try(:description)
	json.is_active		@document.try(:is_active)
	begin
		json.avatar @document.try(:avatar).url
	  json.avatar_file_name @document.try(:avatar_file_name)
		if @document.avatar_file_name.nil? or @document.avatar_file_name.blank?
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