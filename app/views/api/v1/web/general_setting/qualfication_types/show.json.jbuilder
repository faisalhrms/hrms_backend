json.qualfication_type do
  json.id           @qualfication_type.try(:id)
  json.name         @qualfication_type.try(:name)
  json.is_active    @qualfication_type.try(:is_active)
  json.description  @qualfication_type.try(:description)
end