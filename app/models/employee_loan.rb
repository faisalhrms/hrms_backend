class EmployeeLoan < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee
	has_many 		:employee_loan_details,   	:dependent => :destroy

	validate 		:previous_applied_loan

	# Previous Applied Loan Validation
	def previous_applied_loan
		active_loan_status = false
		if self.id.present?
			EmployeeLoan.where.not(id:self.id).where(:employee_id => self.employee_id).each do |employee_loan|
				if employee_loan.is_cleared == false
					active_loan_status = true	
				end
			end
		else
			EmployeeLoan.where(:employee_id => self.employee_id).each do |employee_loan|
				if employee_loan.is_cleared == false
					active_loan_status = true	
				end
			end
		end
		if active_loan_status == true
			self.errors.add(:base, "Already Applied Loan is not Cleared. You can't apply loan again")
		end
	end

	def self.employee_loan_amount(employee, transaction_month)
		employee_loan = EmployeeLoan.find_by(:is_cleared => false, :employee_id => employee.id)
		if employee_loan.nil?
			return 0
		else
			employee_loan_detail = employee_loan.employee_loan_details.where(:is_cleared => false, :status => "UnPaid", :formated_month => transaction_month).last
			if employee_loan_detail.nil?
				return 0
			else
				return employee_loan_detail.installment_amount
			end
		end
	end





	def self.mark_as_cleared(employee, transaction_month)
		employee_loan = EmployeeLoan.find_by(:is_cleared => false, :employee_id => employee.id)
		if not employee_loan.nil?	
			employee_loan_detail = employee_loan.employee_loan_details.where(:is_cleared => false, :status => "UnPaid", :formated_month => transaction_month).last
			if not employee_loan_detail.nil?
				employee_loan_detail.is_cleared = true
				employee_loan_detail.status = "Paid"
				employee_loan_detail.save
			end
		end
	end

	def self.employee_loan_tax_amount(employee, transaction_month)
		employee_loan = EmployeeLoan.find_by(:is_cleared => false, :employee_id => employee.id)
		if employee_loan.nil?
			return 0
		else
			employee_loan_detail = employee_loan.employee_loan_details.where(:is_cleared => false, :status => "UnPaid", :formated_month => transaction_month).last
			if employee_loan_detail.nil?
				return 0
			else
				return employee_loan_detail.loan_interest_amount
			end
		end
	end

	def self.employee_loan_tax_amount_yearly(employee, fiscal_year)
		employee_loan = EmployeeLoan.find_by(:is_cleared => false, :employee_id => employee.id)
		if employee_loan.nil?
			return 0
		else
			return employee_loan.employee_loan_details.where(:installment_date => fiscal_year.start_date.to_date..Time.now.end_of_month.to_date).sum(:loan_interest_amount)
		end
	end

	def company_name
		if self.company.nil?
			return "-"
		else
			self.company.name
		end
	end

	def employee_name
		if self.employee.nil?
			return "-"
		else
			self.employee.full_name
		end
	end

	def employee_code
		if self.employee.nil?
			return "-"
		else
			self.employee.employee_code
		end
	end

end
