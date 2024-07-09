class FixedPayItem < ApplicationRecord

	####### Relations #########
  belongs_to 	:company
  belongs_to 	:pay_item
  belongs_to 	:employee

  validate 		:check_active_item
	
	def check_active_item
		already_active_item = false
		if self.id.present?
			FixedPayItem.where.not(id:self.id).where(:pay_item_id => self.pay_item_id, :employee_id => self.employee_id).each do |fixed_pay_item|
				if fixed_pay_item.is_active == true
					if self.is_active == true
						already_active_item = true	
					end
				end
			end
		else
			FixedPayItem.where(:pay_item_id => self.pay_item_id, :employee_id => self.employee_id).each do |fixed_pay_item|
				if fixed_pay_item.is_active == true
					if self.is_active == true
						already_active_item = true	
					end
				end
			end
		end
		if already_active_item == true
			self.errors.add(:base, "You are not allowed to created more than 1 Active Item")
		end
	end

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def pay_item_name
  	if self.pay_item.nil?
  		return "-"
  	else
  		return self.pay_item.name
  	end
  end

  def employee_name
  	if self.employee.nil?
  		return "-"
  	else
  		return self.employee.full_name
  	end
  end

  def employee_code
  	if self.employee.nil?
  		return "-"
  	else
  		return self.employee.employee_code
  	end
  end

end
