class LeaveYear < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company

	has_many		:leave_allocations, 		:dependent => :restrict_with_error

	validate 		:check_active_leave_year

	# Active Leave Year Validation
	def check_active_leave_year
		already_active_year = false
		if self.id.present?
			LeaveYear.where.not(id:self.id).where(:company_id => self.company_id).each do |leave_year|
				if leave_year.is_active == true
					if self.is_active == true
						already_active_year = true	
					end
				end
			end
		else
			LeaveYear.where(:company_id => self.company_id).each do |leave_year|
				if leave_year.is_active == true
					if self.is_active == true
						already_active_year = true	
					end
				end
			end
		end
		if already_active_year == true
			self.errors.add(:base, "You are not allowed to activate more than 1 Leave Year")
		end
	end

end
