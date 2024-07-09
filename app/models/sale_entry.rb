class SaleEntry < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch

	validates :sale_month, :uniqueness => { scope: :branch_id }

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

	def branch_name
		if self.branch.nil?
  		return "-"
  	else
  		return self.branch.name
  	end
	end

end
