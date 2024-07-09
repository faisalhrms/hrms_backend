json.leave_years @leave_years do |leave_year|
  json.id							leave_year.try(:id)
  json.name 					leave_year.try(:name)
  json.start_date 		leave_year.try(:start_date).strftime("%B %-d, %Y")
  json.end_date 			leave_year.try(:end_date).strftime("%B %-d, %Y")
  json.is_active 			leave_year.try(:is_active)
end