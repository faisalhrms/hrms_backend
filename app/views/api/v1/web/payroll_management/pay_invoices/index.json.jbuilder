json.pay_invoices @pay_invoices.each do |pay_invoice|
	json.id 								pay_invoice.try(:id)
	json.employee_name 			pay_invoice.employee_name
	json.employee_code 			pay_invoice.employee_code
	json.invoice_number 		pay_invoice.try(:invoice_number)
	json.pay_month 					pay_invoice.try(:pay_month)
	json.is_locked 					pay_invoice.try(:is_locked)
	if pay_invoice.is_locked == true
		json.slip_status "Paid"
	else
		json.slip_status "Not Paid"
	end
end