class Document < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to :company

	has_attached_file :avatar,
										:url => "#{ENV['APP_URL']}/system/:class/:attachment/:id/:style/:filename",
										:path => ":rails_root/public/system/:class/:attachment/:id/:style/:filename",
										:default_url => "#{ENV['APP_URL']}/system/no_image.png"

	validates_attachment_content_type :avatar, :content_type => [ "application/pdf", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "text/plain", "image/jpg", "image/jpeg", "image/png", "image/gif" ]
end
