class District < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:country
	belongs_to 	:state
	belongs_to 	:division

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

  def division_name
  	if self.division.nil?
  		return "-"
  	else
  		return self.division.name
  	end
  end

end
