json.fiscal_year do
  json.id							@fiscal_year.try(:id)
	json.company_id			@fiscal_year.try(:company_id)
	json.name						@fiscal_year.try(:name)
	json.description		@fiscal_year.try(:description)
	json.start_date			@fiscal_year.try(:start_date)
	json.end_date				@fiscal_year.try(:end_date)
	json.is_active			@fiscal_year.try(:is_active)
end