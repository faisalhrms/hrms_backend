if params[:is_taxable] == "false"
	opening_balance = params[:loan_amount].to_i
	json.employee_loan_details Array.new(params[:no_of_installment].to_i).each_index do |index|
		principle_installment_amount = params[:monthly_installment].to_i
		installment_amount = params[:monthly_installment].to_i
		closing_balance = opening_balance.to_i - installment_amount.to_i
		json.installment_date (params[:loan_start_date].to_date + index.month).strftime("%B %Y")
		json.opening_balance opening_balance
		json.loan_interest_amount 0
		json.principle_installment_amount principle_installment_amount
		json.installment_amount installment_amount
		if closing_balance < 0
			closing_balance = 0
		end
		json.closing_balance closing_balance
		json.status "UnPaid"
		json.remarks ""
		opening_balance = closing_balance
	end
else
	annual_interest_rate = params[:annual_interest_rate].to_f
	formula_value = (1-((1+((annual_interest_rate.to_f/100.to_f).to_f/12.to_f).to_f).to_f**-params[:no_of_installment].to_f).to_f).to_f/((annual_interest_rate.to_f/100.to_f).to_f/12.to_f).to_f
	opening_balance = params[:loan_amount].to_i
	per_month_loan_installment = opening_balance.to_f/formula_value.to_f
	json.employee_loan_details Array.new(params[:no_of_installment].to_i).each_index do |index|
		loan_interest_amount = (((opening_balance/12.0)/100.0)*annual_interest_rate)
		principle_installment_amount = per_month_loan_installment.to_f.round - loan_interest_amount.to_f.round
		installment_amount = params[:monthly_installment].to_i
		closing_balance = opening_balance.to_f.round - params[:monthly_installment].to_i
		if closing_balance < 0
			closing_balance = 0
		end
		json.installment_date (params[:loan_start_date].to_date + index.month).strftime("%B %Y")
		json.opening_balance opening_balance
		json.loan_interest_amount loan_interest_amount.to_f.round
		json.principle_installment_amount principle_installment_amount
		json.installment_amount installment_amount
		json.closing_balance closing_balance
		json.status "UnPaid"
		json.remarks ""
		opening_balance = closing_balance
	end
end