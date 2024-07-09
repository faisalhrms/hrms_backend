json.employee_advance do
	json.id 											@employee_advance.try(:id)
	json.company_id								@employee_advance.try(:company_id)
	json.employee_id							@employee_advance.try(:employee_id)
	json.gross_salary							@employee_advance.try(:gross_salary)
	json.advance_amount						@employee_advance.try(:advance_amount)
	json.advance_percentage				@employee_advance.try(:advance_percentage)
	json.advance_date							@employee_advance.try(:advance_date)
	json.pay_back_date						@employee_advance.try(:pay_back_date)
	json.pay_back_month						@employee_advance.try(:pay_back_month)
	json.is_cleared								@employee_advance.try(:is_cleared)
	json.combine_name 						"#{@employee_advance.employee_code} | #{@employee_advance.employee_name}"
end