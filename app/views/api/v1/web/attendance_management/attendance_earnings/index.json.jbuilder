json.attendance_earnings @attendance_earnings.each do |attendance_earning|
	json.id 										attendance_earning.try(:id)
	json.name 									attendance_earning.try(:name)
	json.earning_from 					attendance_earning.try(:earning_from)
	json.earning_type 					attendance_earning.try(:earning_type)
	json.earning_value 					attendance_earning.try(:earning_value)
  json.working_days 					attendance_earning.try(:working_days)
end