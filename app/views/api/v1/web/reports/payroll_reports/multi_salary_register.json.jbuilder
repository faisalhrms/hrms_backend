pay_item_ids = []
@pay_executions.each do |pay_execution|
	pay_execution.item_execution_details.where(:status => "Allowed").each do |item_execution_detail|
		pay_item_ids << item_execution_detail.pay_item_id
	end
end
json.pay_items PayItem.where(:id => pay_item_ids).order('sort_order ASC').each do |pay_item|
	if pay_item.name != "Attendance Deduction"
		json.id  		pay_item.id
		json.name  	pay_item.name
	end
end

json.salary_details @pay_invoices.each do |pay_invoice|
	json.full_name								pay_invoice.employee_name
	json.employee_code 						pay_invoice.employee_code
	json.grade_name 							pay_invoice.grade_name
	json.designation_name 				pay_invoice.designation_name
	json.location_name 						pay_invoice.location_name
	json.branch_name 							pay_invoice.branch_name
	json.department_name 					pay_invoice.department_name
	json.gross_salary							pay_invoice.actual_salary
	json.item_details 						pay_invoice.pay_invoice_details.order('sort_order ASC').each do |item_detail|
		if item_detail.item_name != "Attendance Deduction"
			json.item_amount 									item_detail.amount.round
		end
	end
	json.attendance_deduction			pay_invoice.pay_invoice_details.where(:item_name => "Attendance Deduction").sum(:amount).round
	json.income_tax								pay_invoice.monthly_tax.round
	json.total_earning 						pay_invoice.total_earning.round
	json.total_deduction 					(pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)
	json.net_payable							(pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
end