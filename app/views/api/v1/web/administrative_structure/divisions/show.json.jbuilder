json.division do
  json.id           		@division.try(:id)
  json.name         		@division.try(:name)
  json.country_id   		@division.try(:country_id)
  json.state_id  				@division.try(:state_id)
  json.country_name			@division.country_name
	json.state_name				@division.state_name
end