json.qualification_program do
  json.id           @qualification_program.try(:id)
  json.name         @qualification_program.try(:name)
  json.is_active    @qualification_program.try(:is_active)
  json.description  @qualification_program.try(:description)
end