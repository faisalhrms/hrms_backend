json.leave_year do
  json.id							@leave_year.try(:id)
	json.company_id			@leave_year.try(:company_id)
	json.name						@leave_year.try(:name)
	json.description		@leave_year.try(:description)
	json.start_date			@leave_year.try(:start_date)
	json.end_date				@leave_year.try(:end_date)
	json.is_active			@leave_year.try(:is_active)
end