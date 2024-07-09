class Division < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:country
	belongs_to 	:state

	has_many		:districts, :dependent => :restrict_with_error
	has_many		:tehsils, 	:dependent => :restrict_with_error

	def country_name
  	if self.country.nil?
  		return "-"
  	else
  		return self.country.name
  	end
  end

  def state_name
  	if self.state.nil?
  		return "-"
  	else
  		return self.state.name
  	end
  end
  
end
