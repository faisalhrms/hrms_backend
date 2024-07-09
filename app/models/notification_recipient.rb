class NotificationRecipient < ApplicationRecord

	####### Relation Ship #########
	belongs_to :recievable, polymorphic: true
	belongs_to :notification
	
end
