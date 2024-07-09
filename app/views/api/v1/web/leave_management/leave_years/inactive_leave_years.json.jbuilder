json.leave_years @leave_years do |leave_year|
  json.id							leave_year.try(:id)
  json.name 					leave_year.try(:name)
end