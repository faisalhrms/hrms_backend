json.tehsil do
  json.id           		@tehsil.try(:id)
  json.name         		@tehsil.try(:name)
  json.country_id   		@tehsil.try(:country_id)
  json.state_id  				@tehsil.try(:state_id)
  json.division_id  		@tehsil.try(:division_id)
  json.district_id  		@tehsil.try(:district_id)
  json.country_name			@tehsil.country_name
	json.state_name				@tehsil.state_name
	json.division_name		@tehsil.division_name
	json.district_name		@tehsil.district_name
end