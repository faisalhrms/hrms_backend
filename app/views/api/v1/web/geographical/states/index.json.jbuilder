json.states @states do |state|
  json.id   					state.try(:id)
  json.name 					state.try(:name)
end