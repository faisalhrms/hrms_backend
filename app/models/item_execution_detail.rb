class ItemExecutionDetail < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:pay_execution
	belongs_to 	:pay_item

	scope :get_by_pay_execution, -> (pay_execution_id){where(pay_execution_id: pay_execution_id)}
	scope :allowed, -> {where(status: "Allowed")}

	def pay_item_name
  	if self.pay_item.nil?
  		return "-"
  	else
  		return self.pay_item.name
  	end
  end

end
