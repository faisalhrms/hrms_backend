class BreakTime < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :time_slot_id }
	validates :code, :uniqueness => { scope: :time_slot_id }
	
	####### Relation Ship #########
	belongs_to 	:time_slot

end
