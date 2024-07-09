class LeaveRequestDetail < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:leave_request
	belongs_to 	:leave_type

end
