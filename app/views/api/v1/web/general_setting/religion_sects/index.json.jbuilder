json.religion_sects @religion_sects do |religion_sect|
  json.id   			religion_sect.try(:id)
  json.name 			religion_sect.try(:name)
end