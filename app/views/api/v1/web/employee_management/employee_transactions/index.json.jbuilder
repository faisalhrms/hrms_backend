json.employee_transactions @employee_transactions.each do |employee_transaction|
	json.employee_id 							employee_transaction.try(:employee_id)
	json.transaction_type 				employee_transaction.try(:transaction_type)
	if employee_transaction.transaction_type == "Employee Status"
		json.old_value 							employee_transaction.try(:old_employee_status)
		json.new_value 							employee_transaction.try(:new_employee_status)
	elsif employee_transaction.transaction_type == "Employment Status"
		json.old_value 							employee_transaction.try(:old_employment_status)
		json.new_value 							employee_transaction.try(:new_employment_status)
	elsif employee_transaction.transaction_type == "Gross Salary"
		json.old_value 							employee_transaction.try(:old_gross_salary)
		json.new_value 							employee_transaction.try(:new_gross_salary)
	elsif employee_transaction.transaction_type == "Change Joining Date"
		json.old_value 							ReportFormat.date_format(employee_transaction.old_joining_date)
		json.new_value 							ReportFormat.date_format(employee_transaction.new_joining_date)
	elsif employee_transaction.transaction_type == "Line Manager"
		json.old_value 							employee_transaction.prev_line_manager_name
		json.new_value 							employee_transaction.current_line_manager_name
	elsif employee_transaction.transaction_type == "End of Employment"
		json.old_value							"-"
		json.new_value							employee_transaction.left_type
	elsif employee_transaction.transaction_type == "Transfer"
		if employee_transaction.transfer_type == "Branch"
			json.transaction_type 			"#{employee_transaction.transaction_type} #{employee_transaction.transfer_type}"
			json.old_value							employee_transaction.prve_branch_name
			json.new_value							employee_transaction.current_branch_name
		elsif employee_transaction.transfer_type == "Department"
			json.transaction_type 			"#{employee_transaction.transaction_type} #{employee_transaction.transfer_type}"
			json.old_value							employee_transaction.prve_department_name
			json.new_value							employee_transaction.current_department_name
		else
			json.old_value							"-"
			json.new_value							"-"	
		end
	elsif employee_transaction.transaction_type == "Change Grade"
		json.old_value							employee_transaction.prev_grade_name
		json.new_value							employee_transaction.current_grade_name
	elsif employee_transaction.transaction_type == "Change Designation"
		json.old_value							employee_transaction.prev_designation_name
		json.new_value							employee_transaction.current_designation_name
	elsif employee_transaction.transaction_type == "Change Job Title"
		json.old_value							employee_transaction.prev_job_title_name
		json.new_value							employee_transaction.current_job_title_name
	elsif employee_transaction.transaction_type == "Change Employee Type"
		json.old_value							employee_transaction.prev_employee_type_name
		json.new_value							employee_transaction.current_employee_type_name
	elsif employee_transaction.transaction_type == "Probation Extension"
		json.old_value							ReportFormat.date_format(employee_transaction.old_confimration_due_date)
		json.new_value							ReportFormat.date_format(employee_transaction.new_confimration_due_date)
	elsif employee_transaction.transaction_type == "Change Salary Unit"
		json.old_value							"#{employee_transaction.prev_salary_unit_name} | #{employee_transaction.prev_cost_center_name}"
		json.new_value							"#{employee_transaction.current_salary_unit_name} | #{employee_transaction.current_cost_center_name}"
	elsif employee_transaction.transaction_type == "Employee Code"
		json.old_value							employee_transaction.old_employee_code
		json.new_value							employee_transaction.new_employee_code
	
	else
		json.old_value								"-"
		json.new_value								"-"
	end
	json.transaction_date 				ReportFormat.date_format(employee_transaction.transaction_date)
end





