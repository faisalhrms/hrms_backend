class AttendanceDeduction < ApplicationRecord

	########## Validation ############
	validates :name, 	:uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:attendance_type

  has_many    :attendance_relaxation_slabs,     :dependent => :restrict_with_error
  has_many    :absent_policies,                 :dependent => :restrict_with_error
  has_many    :early_left_slabs,                :dependent => :restrict_with_error
  has_many    :missing_punches,                 :dependent => :restrict_with_error

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def attendance_type_name
  	if self.attendance_type.nil?
  		return "-"
  	else
  		return self.attendance_type.name
  	end
  end

end
