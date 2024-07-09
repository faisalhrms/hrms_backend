json.salary_unit do
  json.id           @salary_unit.try(:id)
  json.name         @salary_unit.try(:name)
  json.is_active    @salary_unit.try(:is_active)
  json.description  @salary_unit.try(:description)
  json.company_id  	@salary_unit.try(:company_id)
end