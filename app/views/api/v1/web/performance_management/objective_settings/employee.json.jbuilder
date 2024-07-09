index_count = 0
json.employees @employees.each do |employee|
  json.index_value								index_count
  json.id 												employee.try(:id)
  json.employee_code 												employee.try(:employee_code)
  json.first_name 						    employee.try(:first_name)
  json.last_name 							    employee.try(:last_name)
  index_count = index_count + 1
end