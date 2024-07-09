json.employee_loan do
	json.id 											@employee_loan.try(:id)
	json.loan_type 								@employee_loan.try(:loan_type)
	json.loan_amount 							@employee_loan.try(:loan_amount)
	json.no_of_installment 				@employee_loan.try(:no_of_installment)
	json.installment_amount 			@employee_loan.try(:installment_amount)
	json.employee_id 							@employee_loan.try(:employee_id)
	json.company_id 							@employee_loan.try(:company_id)
	json.is_cleared 							@employee_loan.try(:is_cleared)
	json.combine_name 						"#{@employee_loan.employee_code} | #{@employee_loan.employee_name}"
	json.monthly_installment 			@employee_loan.try(:monthly_installment)
	json.gross_salary 						@employee_loan.try(:gross_salary)
	json.is_taxable 							@employee_loan.try(:is_taxable)
	json.principle_loan_amount 		@employee_loan.try(:principle_loan_amount)
	json.annual_interest_rate 		@employee_loan.try(:annual_interest_rate)
	if not @employee_loan.loan_start_date.nil?
		json.loan_start_date 				@employee_loan.try(:loan_start_date).strftime("%B %Y")
	else
		json.loan_start_date "-"
	end
	if not @employee_loan.pay_back_date.nil?
		json.pay_back_date 					@employee_loan.try(:pay_back_date).strftime("%B %Y")
	else
		json.pay_back_date "-"
	end
	editable_status = false
	json.employee_loan_details 		@employee_loan.employee_loan_details.order('id ASC').each do |employee_loan_detail|
		json.employee_loan_detail_id 			employee_loan_detail.try(:id)
		json.installment_amount 					employee_loan_detail.try(:installment_amount)
		if not employee_loan_detail.installment_date.nil?
			json.installment_date 					employee_loan_detail.try(:installment_date).strftime("%B %Y")
		else
			json.installment_date "-"
		end
		json.is_cleared 									employee_loan_detail.try(:is_cleared)
		if employee_loan_detail.status == "UnPaid"
			if editable_status == true
				json.is_editable 							false
			else
				editable_status = true
				json.is_editable 							true	
			end
		else
			json.is_editable 								false
		end
		json.is_cleared 									employee_loan_detail.try(:is_cleared)
		json.opening_balance 							employee_loan_detail.try(:opening_balance)
		json.closing_balance 							employee_loan_detail.try(:closing_balance)
		json.principle_installment_amount employee_loan_detail.try(:principle_installment_amount)
		json.loan_interest_amount 				employee_loan_detail.try(:loan_interest_amount)
		json.status 											employee_loan_detail.try(:status)
		json.remarks 											employee_loan_detail.try(:remarks)
	end
end