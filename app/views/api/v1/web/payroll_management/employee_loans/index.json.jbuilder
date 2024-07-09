json.employee_loans @employee_loans.each do |employee_loan|
  json.id 						employee_loan.id
  json.loan_type 			employee_loan.loan_type
  json.loan_amount 		employee_loan.loan_amount
  if employee_loan.is_cleared == true
  	json.status 			"Cleared"
  else
  	json.status 			"Pending"
  end
  json.employee_code 		employee_loan.employee_code
  json.employee_name 		employee_loan.employee_name
  json.is_taxable 			employee_loan.try(:is_taxable)
end