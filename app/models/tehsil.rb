class Tehsil < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:country
	belongs_to 	:state
	belongs_to 	:division
	belongs_to 	:district

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

  def district_name
  	if self.district.nil?
  		return "-"
  	else
  		return self.district.name
  	end
  end

end
