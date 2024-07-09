class EmployeeTaxableIncome < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee
	belongs_to 	:fiscal_year
	belongs_to 	:pay_invoice
	belongs_to 	:pay_execution

end
