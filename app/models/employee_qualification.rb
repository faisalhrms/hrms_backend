class EmployeeQualification < ApplicationRecord

	has_attached_file :avatar,
										:url => "#{ENV['APP_URL']}/system/:class/:attachment/:id/:style/:filename",
										:path => ":rails_root/public/system/:class/:attachment/:id/:style/:filename",
										:default_url => "#{ENV['APP_URL']}/system/profile-placeholder.jpg"

	validates_attachment_content_type :avatar, :content_type => [ "application/pdf", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "text/plain", "image/jpg", "image/jpeg", "image/png", "image/gif" ]

	####### Relation Ship #########
	belongs_to 	:employee
	belongs_to 	:qualfication_type
	belongs_to 	:qualification_program
	belongs_to 	:specialization

	def program_name
		if self.qualification_program.nil?
  		return "-"
  	else
  		return self.qualification_program.name
  	end
	end

	def specialization_name
		if self.specialization.nil?
  		return "-"
  	else
  		return self.specialization.name
  	end
	end

	def employee_name
		if self.employee.nil?
			return "-"
		else
			self.employee.full_name
		end
	end

	def employee_code
		if self.employee.nil?
			return "-"
		else
			self.employee.employee_code
		end
	end

end
