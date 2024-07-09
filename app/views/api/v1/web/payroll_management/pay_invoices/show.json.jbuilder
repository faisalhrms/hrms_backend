json.pay_invoice do
	json.id 								@pay_invoice.try(:id)
	json.monthly_tax 				@pay_invoice.monthly_tax.to_f.round
end