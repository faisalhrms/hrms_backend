json.competencies @competencies do |competency|
  json.id   			competency.try(:id)
  json.title 			competency.try(:title)
  json.description competency.try(:description)
  json.rating 		competency.try(:rating)
end