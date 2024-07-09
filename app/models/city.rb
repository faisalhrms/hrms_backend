class City < ApplicationRecord

	####### Relation Ship #########
	belongs_to :state

  def state_name
  	if self.state.nil?
  		return "-"
  	else
  		return self.state.name
  	end
  end

end
