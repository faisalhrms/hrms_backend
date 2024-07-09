json.employee_type do
  json.id           @employee_type.try(:id)
  json.name         @employee_type.try(:name)
  json.is_active    @employee_type.try(:is_active)
  json.description  @employee_type.try(:description)
end