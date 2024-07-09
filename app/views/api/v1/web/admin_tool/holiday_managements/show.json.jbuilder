json.holiday_management do
  json.id											@holiday_management.try(:id)
	json.company_id							@holiday_management.try(:company_id)
	json.name										@holiday_management.try(:name)
	json.code										@holiday_management.try(:code)
	json.description						@holiday_management.try(:description)
	json.start_date							@holiday_management.try(:start_date)
	json.end_date								@holiday_management.try(:end_date)
	json.is_active							@holiday_management.try(:is_active)
	json.religion_id						@holiday_management.try(:religion_id)
	json.specific_religion			@holiday_management.try(:specific_religion)
	json.location_id			      @holiday_management.try(:location_id)
  json.branch_ids 						@holiday_management.try(:branch_ids).try(:split, ",").try(:map, &:to_i)
end