json.sub_department do
  json.id           		@sub_department.try(:id)
  json.company_id				@sub_department.try(:company_id)
	json.department_id		@sub_department.try(:department_id)
	json.name							@sub_department.try(:name)
	json.code							@sub_department.try(:code)
	json.description			@sub_department.try(:description)
	json.is_active				@sub_department.try(:is_active)
end