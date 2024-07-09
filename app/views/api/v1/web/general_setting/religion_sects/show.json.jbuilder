json.religion_sect do
  json.id           @religion_sect.try(:id)
  json.name         @religion_sect.try(:name)
end