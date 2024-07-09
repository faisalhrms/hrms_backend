class PayRollReportData

	def self.employee_eobi_value(pay_invoice)
		return PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "EOBI").sum(:amount)
	end

	def self.employeer_eobi_value(pay_invoice)
		employee_taxable_income = pay_invoice.employee_taxable_income
		return employee_taxable_income.employeer_eobi_value
	end

	def self.employee_pf_value(pay_invoice)
		return PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => ["Provident Fund", "Arrears Provident Fund"]).sum(:amount)
	end

	def self.round_gross_pay(pay_invoice, gross_pay)
		effective_date = Date.new(2021, 2, 1)
		((pay_invoice.actual_salary - gross_pay).abs <= 2 and pay_invoice.pay_execution.pay_month.to_date >= effective_date) ? pay_invoice.actual_salary : gross_pay
	end

	def self.employee_total_pf_cont(pay_invoice)
		employee = pay_invoice.employee
		fiscal_year = FiscalYear.where(is_active: true).last
		pay_execution_ids = PayExecution.where(company_id: employee.company_id, location_id: employee.location_id).where('pay_month >= ? AND pay_month <= ?', fiscal_year.start_date.to_date, fiscal_year.end_date.to_date).collect(&:id)
		pay_invoice_ids = PayInvoice.where(employee_id: employee.id, pay_execution_id: pay_execution_ids, status: true).collect(&:id)
		return PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_type => "Deduction", :item_name => ["Provident Fund", "Arrears Provident Fund"]).sum(:amount)
	end

	def self.employeer_pf_value(pay_invoice)
		employee_taxable_income = pay_invoice.employee_taxable_income
		return employee_taxable_income.employeer_pf_value + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => ["Arrears Provident Fund"]).sum(:amount)
	end

	def self.basic_salary_value(pay_invoice)
		return PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Earning", :item_name => "Basic Salary").sum(:amount)
	end

	def self.monthly_tax_amount(pay_invoice)
		employee_taxable_income = pay_invoice.employee_taxable_income
		return employee_taxable_income.monthly_tax_amount
	end

end	