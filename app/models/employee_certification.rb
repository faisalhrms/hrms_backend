class EmployeeCertification < ApplicationRecord

	has_attached_file :avatar,
										:url => "#{ENV['APP_URL']}/system/:class/:attachment/:id/:style/:filename",
										:path => ":rails_root/public/system/:class/:attachment/:id/:style/:filename",
										:default_url => "#{ENV['APP_URL']}/system/profile-placeholder.jpg"

	validates_attachment_content_type :avatar, :content_type => [ "application/pdf", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "text/plain", "image/jpg", "image/jpeg", "image/png", "image/gif" ]

	####### Relation Ship #########
	belongs_to 	:employee
end
