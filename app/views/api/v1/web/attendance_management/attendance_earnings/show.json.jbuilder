json.attendance_earning do
	json.id 									@attendance_earning.try(:id)
	json.company_id						@attendance_earning.try(:company_id)
	json.name									@attendance_earning.try(:name)
	json.earning_from					@attendance_earning.try(:earning_from)
	json.earning_type					@attendance_earning.try(:earning_type)
	json.multiplex						@attendance_earning.try(:multiplex)
	json.multiplex_allowed		@attendance_earning.try(:multiplex_allowed)
	json.earning_value				@attendance_earning.try(:earning_value)
	json.upper_cap						@attendance_earning.try(:upper_cap)
	json.upper_cap_limit			@attendance_earning.try(:upper_cap_limit)
  json.rest_upper_cap				@attendance_earning.try(:rest_upper_cap)
  json.rest_upper_cap_limit	@attendance_earning.try(:rest_upper_cap_limit)
  json.regular_upper_cap				@attendance_earning.try(:regular_upper_cap)
  json.regular_upper_cap_limit	@attendance_earning.try(:regular_upper_cap_limit)
	json.description					@attendance_earning.try(:description)
  json.working_days					@attendance_earning.try(:working_days)
	if @attendance_earning.holiday_ids.nil?
    json.holiday_ids	 			nil
  else
    json.holiday_ids 				@attendance_earning.holiday_ids.split(',').map(&:to_i)
  end
end