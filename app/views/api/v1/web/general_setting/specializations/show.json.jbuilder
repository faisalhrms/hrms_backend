json.specialization do
  json.id           @specialization.try(:id)
  json.name         @specialization.try(:name)
  json.is_active    @specialization.try(:is_active)
  json.description  @specialization.try(:description)
end