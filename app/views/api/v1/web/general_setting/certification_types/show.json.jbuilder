json.certification_type do
  json.id           @certification_type.try(:id)
  json.name         @certification_type.try(:name)
  json.is_active    @certification_type.try(:is_active)
  json.description  @certification_type.try(:description)
end