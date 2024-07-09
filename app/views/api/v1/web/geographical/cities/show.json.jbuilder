json.city do
  json.id           	@city.try(:id)
  json.name         	@city.try(:name)
  json.state_name   	@city.state_name
  json.country_name   @city.state.country_name
end