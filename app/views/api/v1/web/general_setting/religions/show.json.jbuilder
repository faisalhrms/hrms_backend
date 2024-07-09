json.religion do
  json.id           @religion.try(:id)
  json.name         @religion.try(:name)
end