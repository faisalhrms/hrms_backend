class State < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:country
	
	has_many		:divisions
	has_many		:districts
	has_many		:tehsils

	def country_name
  	if self.country.nil?
  		return "-"
  	else
  		return self.country.name
  	end
  end

end
