json.state do
  json.id           	@state.try(:id)
  json.name         	@state.try(:name)
  json.country_name 	@state.country_name
end