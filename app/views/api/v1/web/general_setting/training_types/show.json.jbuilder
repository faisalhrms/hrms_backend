json.training_type do
  json.id           @training_type.try(:id)
  json.name         @training_type.try(:name)
  json.is_active    @training_type.try(:is_active)
  json.description  @training_type.try(:description)
end