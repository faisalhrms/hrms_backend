json.job_title do
  json.id           @job_title.try(:id)
  json.name         @job_title.try(:name)
  json.is_active    @job_title.try(:is_active)
  json.description  @job_title.try(:description)
  json.company_id  	@job_title.try(:company_id)
end