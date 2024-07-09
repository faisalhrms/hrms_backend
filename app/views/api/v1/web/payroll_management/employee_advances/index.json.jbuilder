json.employee_advances @employee_advances.each do |employee_advance|
  json.id 						    employee_advance.id
  json.advance_amount 		employee_advance.advance_amount
  json.pay_back_month     employee_advance.pay_back_month
  json.employee_code      employee_advance.employee_code
  json.employee_name      employee_advance.employee_name
  if employee_advance.is_cleared == true
  	json.status 			    "Cleared"
  else
  	json.status 			    "Pending"
  end
end