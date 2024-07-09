class FiscalYear < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company

	has_many 		:pay_executions,   	:dependent => :restrict_with_error

	validate 		:check_active_fiscal_year

	scope :active, -> {find_by(is_active: true)}
	# Active Fiscal Year Validation
	def check_active_fiscal_year
		already_active_year = false
		if self.id.present?
			FiscalYear.where.not(id:self.id).where(:company_id => self.company_id).each do |fiscal_year|
				if fiscal_year.is_active == true
					if self.is_active == true
						already_active_year = true	
					end
				end
			end
		else
			FiscalYear.where(:company_id => self.company_id).each do |fiscal_year|
				if fiscal_year.is_active == true
					if self.is_active == true
						already_active_year = true	
					end
				end
			end
		end
		if already_active_year == true
			self.errors.add(:base, "You are not allowed to activate more than 1 Fiscal Year")
		end
	end

end
