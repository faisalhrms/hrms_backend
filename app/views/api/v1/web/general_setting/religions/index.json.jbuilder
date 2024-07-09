json.religions @religions do |religion|
  json.id   			religion.try(:id)
  json.name 			religion.try(:name)
end