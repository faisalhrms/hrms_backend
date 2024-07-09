class LeaveType < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :location_id }
	validates :short_name, 	:uniqueness => { scope: :location_id }
		
	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location

	has_many		:leave_allocations, 							:dependent => :restrict_with_error
	has_many		:leave_requests, 									:dependent => :restrict_with_error
	has_many		:leave_transaction_histories
	has_many		:composite_leave_types, 					:dependent => :destroy

	def special_leave_allocation_year
		if self.no_of_years == "After Every 1 Year"
			return 1 * 365
		elsif self.no_of_years == "After Every 2 Year"
			return 2 * 365
		elsif self.no_of_years == "After Every 3 Year"
			return 3 * 365
		elsif self.no_of_years == "After Every 4 Year"
			return 4 * 365
		elsif self.no_of_years == "After Every 5 Year"
			return 5 * 365
		elsif self.no_of_years == "After Every 6 Year"
			return 6 * 365
		elsif self.no_of_years == "After Every 7 Year"
			return 7 * 365
		elsif self.no_of_years == "After Every 8 Year"
			return 8 * 365
		elsif self.no_of_years == "After Every 9 Year"
			return 9 * 365
		elsif self.no_of_years == "After Every 10 Year"
			return 10 * 365
		elsif self.no_of_years == "Once in Service Period"
			return 1000 * 365
		end
	end

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def location_name
  	if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
  end

  def verify_experience_type(calculation_in_days, calculation_in_month)
		if self.experience_type == "Day"
			return calculation_in_days
		else
			return calculation_in_month
		end
	end

end
