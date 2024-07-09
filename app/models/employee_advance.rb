class EmployeeAdvance < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee

	validate 		:previous_applied_advance

	# Previous Applied Advance Validation
	def previous_applied_advance
		active_advance_status = false
		if self.id.present?
			EmployeeAdvance.where.not(id:self.id).where(:employee_id => self.employee_id).each do |employee_advance|
				if employee_advance.is_cleared == false
					active_advance_status = true	
				end
			end
		else
			EmployeeAdvance.where(:employee_id => self.employee_id).each do |employee_advance|
				if employee_advance.is_cleared == false
					active_advance_status = true	
				end
			end
		end
		if active_advance_status == true
			self.errors.add(:base, "Already Applied Advance is not Cleared. You can't apply Advance again")
		end
	end

	def self.mark_as_cleared(employee, transaction_month)
		EmployeeAdvance.where(:employee_id => employee.id, :is_cleared => false, :pay_back_month => transaction_month).each do |employee_advance|
			employee_advance.is_cleared = true
			employee_advance.save
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
