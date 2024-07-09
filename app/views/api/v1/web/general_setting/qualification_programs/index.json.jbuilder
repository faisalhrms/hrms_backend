json.qualification_programs @qualification_programs do |qualification_program|
  json.id   			qualification_program.try(:id)
  json.name 			qualification_program.try(:name)
  json.is_active 	qualification_program.try(:is_active)
end