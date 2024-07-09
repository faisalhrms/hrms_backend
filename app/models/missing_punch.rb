class MissingPunch < ApplicationRecord

	########## Validation ############
	validates :name, 		:uniqueness => { scope: :company_id }
	validates :code, 		:uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:attendance_deduction
	belongs_to	:fallback, foreign_key: :fallback_id, :class_name => "AttendanceDeduction"

  has_many    :attendance_structures,           :dependent => :restrict_with_error

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def attendance_deduction_name
  	if self.attendance_deduction.nil?
  		return "-"
  	else
  		return self.attendance_deduction.name
  	end
  end

  def fallback_name
  	if self.fallback.nil?
  		return "-"
  	else
  		return self.fallback.name
  	end
  end

end
