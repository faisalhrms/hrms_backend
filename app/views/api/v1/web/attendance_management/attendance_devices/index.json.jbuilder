index_count = 0
json.attendance_devices @attendance_devices.each do |attendance_device|
	json.id 												attendance_device.try(:id)
	json.index_value								index_count
	json.name 											attendance_device.try(:name)
	json.code 											attendance_device.try(:code)
	json.device_id 									attendance_device.try(:device_id)
	json.device_type 								attendance_device.try(:device_type)
	json.is_active 									attendance_device.try(:is_active)
	index_count = index_count + 1
end