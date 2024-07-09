json.attendance_type do
  json.id           		@attendance_type.try(:id)
  json.name         		@attendance_type.try(:name)
  json.code         		@attendance_type.try(:code)
  json.sort_order 			@attendance_type.try(:sort_order)
  json.is_active    		@attendance_type.try(:is_active)
  json.request_enable   @attendance_type.try(:request_enable)
  json.description  		@attendance_type.try(:description)
  json.company_id  			@attendance_type.try(:company_id)
end