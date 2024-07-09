class CompositeLeaveType < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:leave_type
	belongs_to 	:combine_leave_type, 		foreign_key: :merge_leave_type_id, 	:class_name => "LeaveType"

end
