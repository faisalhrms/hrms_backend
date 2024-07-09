json.general_type do
  json.id           @general_type.try(:id)
  json.name         @general_type.try(:name)
end