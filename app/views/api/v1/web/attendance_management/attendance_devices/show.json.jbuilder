json.attendance_device do
	json.id 												@attendance_device.try(:id)
	json.name												@attendance_device.try(:name)
	json.code												@attendance_device.try(:code)
	json.company_id									@attendance_device.try(:company_id)
	json.is_active									@attendance_device.try(:is_active)
	json.device_id									@attendance_device.try(:device_id)
	json.device_type								@attendance_device.try(:device_type)
	json.device_url									@attendance_device.try(:device_url)
	json.description								@attendance_device.try(:description)
	json.auto_fetch_allowed					@attendance_device.try(:auto_fetch_allowed)
end