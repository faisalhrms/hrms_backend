json.job_titles @job_titles do |job_title|
  json.id   			job_title.try(:id)
  json.name 			job_title.try(:name)
  json.is_active 	job_title.try(:is_active)
end