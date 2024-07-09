class Notification < ApplicationRecord

	####### Relation Ship #########
	belongs_to :notifiable, polymorphic: true
	belongs_to :sendable, 	polymorphic: true

	has_many :recipients, class_name: 'NotificationRecipient', dependent: :destroy

	def self.create_custom_notification(sender, notifiable, recievable, content)
		noti = Notification.create(:sendable => sender, :notifiable => notifiable)
		notiRec = noti.recipients.build(:recievable => recievable)
		notiRec.content = content
		notiRec.save
	end

end
