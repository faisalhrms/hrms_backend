json.holiday_managements @holiday_managements do |holiday_management|
  json.id							holiday_management.try(:id)
  json.name 					holiday_management.try(:name)
  json.code 					holiday_management.try(:code)
  json.start_date 		ReportFormat.date_format(holiday_management.start_date)
  json.end_date 			ReportFormat.date_format(holiday_management.end_date)
  json.is_active 			holiday_management.try(:is_active)
end