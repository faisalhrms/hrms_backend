json.district do
  json.id           		@district.try(:id)
  json.name         		@district.try(:name)
  json.country_id   		@district.try(:country_id)
  json.state_id  				@district.try(:state_id)
  json.division_id  		@district.try(:division_id)
  json.country_name			@district.country_name
	json.state_name				@district.state_name
	json.division_name		@district.division_name
end